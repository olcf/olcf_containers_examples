#ifndef _GNU_SOURCE
#define _GNU_SOURCE
#endif

#include <cstdlib>
#include <cstdio>
#include <cstring>
#include <string>
#include <vector>
#include <sstream>
#include <iomanip>

#include <mpi.h>
#include <omp.h>
#include <sched.h>

#include <cuda_runtime_api.h>

#define cudaErrorCheck(call)                                                    \
do {                                                                            \
    cudaError_t cudaErr = (call);                                               \
    if (cudaErr != cudaSuccess) {                                               \
        fprintf(stderr, "CUDA Error - %s:%d: '%s'\n",                           \
                __FILE__, __LINE__, cudaGetErrorString(cudaErr));               \
        fflush(stderr);                                                         \
        MPI_Abort(MPI_COMM_WORLD, EXIT_FAILURE);                                \
        std::abort();                                                           \
    }                                                                           \
} while (0)

static void report_layout(
    int rank,
    const char *node_name,
    const std::string &visible_gpu_ids,
    const std::string &runtime_gpu_ids,
    const std::string &bus_ids,
    bool have_gpu_info,
    bool report_all_threads)
{
    const int max_threads = omp_get_max_threads();
    std::vector<std::string> thread_lines(max_threads);
    int actual_threads = 0;

#pragma omp parallel default(none)                                              \
    shared(rank, node_name, visible_gpu_ids, runtime_gpu_ids, bus_ids,          \
           have_gpu_info, report_all_threads, thread_lines, actual_threads)
    {
        const int thread_id = omp_get_thread_num();
        const int hwthread = sched_getcpu();

        if (report_all_threads || thread_id == 0) {
            std::ostringstream line;

            line << std::setfill('0')
                 << "MPI " << std::setw(3) << rank
                 << " - OMP " << std::setw(3) << thread_id
                 << " - HWT " << std::setw(3) << hwthread
                 << std::setfill(' ')
                 << " - Node " << node_name;

            if (have_gpu_info) {
                line << " - RT_GPU_ID " << runtime_gpu_ids
                     << " - GPU_ID " << visible_gpu_ids
                     << " - Bus_ID " << bus_ids;
            }

            line << '\n';
            thread_lines[thread_id] = line.str();
        }

#pragma omp single
        {
            actual_threads = omp_get_num_threads();
        }
    }

    std::string output;

    if (report_all_threads) {
        for (int thread_id = 0; thread_id < actual_threads; ++thread_id) {
            output += thread_lines[thread_id];
        }
    } else {
        output = thread_lines[0];
    }

    fwrite(output.data(), 1, output.size(), stdout);
    fflush(stdout);
}

int main(int argc, char *argv[])
{
    MPI_Init(&argc, &argv);

    int size = 0;
    int rank = 0;

    MPI_Comm_size(MPI_COMM_WORLD, &size);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);

    char node_name[MPI_MAX_PROCESSOR_NAME + 1] = {};
    int result_length = 0;

    MPI_Get_processor_name(node_name, &result_length);

    if (result_length >= MPI_MAX_PROCESSOR_NAME) {
        node_name[MPI_MAX_PROCESSOR_NAME] = '\0';
    } else {
        node_name[result_length] = '\0';
    }

    // Short node name: truncate at first '.'
    char *dot = std::strchr(node_name, '.');
    if (dot != nullptr) {
        *dot = '\0';
    }

    const char *cuda_visible_devices = std::getenv("CUDA_VISIBLE_DEVICES");
    const std::string visible_gpu_ids =
        (cuda_visible_devices == nullptr) ? "N/A" : cuda_visible_devices;

    int num_devices = 0;
    cudaError_t count_status = cudaGetDeviceCount(&num_devices);

    if (count_status == cudaErrorNoDevice) {
        num_devices = 0;
    } else {
        cudaErrorCheck(count_status);
    }

    const bool report_all_threads = true;

    if (num_devices == 0) {
        report_layout(
            rank,
            node_name,
            visible_gpu_ids,
            "",
            "",
            false,
            report_all_threads);
    } else {
        std::string runtime_gpu_ids;
        std::string bus_ids;

        for (int device = 0; device < num_devices; ++device) {
            char bus_id[64] = {};

            cudaErrorCheck(
                cudaDeviceGetPCIBusId(
                    bus_id,
                    static_cast<int>(sizeof(bus_id)),
                    device));

            if (device > 0) {
                runtime_gpu_ids += ",";
                bus_ids += ",";
            }

            runtime_gpu_ids += std::to_string(device);

            // Extract bus field from domain:bus:device.function
            // Example: "0000:81:00.0" -> "81"
            std::string full_bus_id(bus_id);
            std::size_t first_colon = full_bus_id.find(':');
            std::size_t second_colon = full_bus_id.find(':', first_colon + 1);

            if (first_colon != std::string::npos &&
                second_colon != std::string::npos) {
                bus_ids += full_bus_id.substr(
                    first_colon + 1,
                    second_colon - first_colon - 1);
            } else {
                bus_ids += full_bus_id;
            }
        }

        report_layout(
            rank,
            node_name,
            visible_gpu_ids,
            runtime_gpu_ids,
            bus_ids,
            true,
            report_all_threads);
    }

    MPI_Finalize();
    return EXIT_SUCCESS;
} 

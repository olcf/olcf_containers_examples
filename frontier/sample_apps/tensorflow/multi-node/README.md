# Tensorflow MNIST example

There are two common ways of distributed training with data parallelism: 1). synchronous training where steps of training are synced across workers and replicas and 2). Asynchronous training where training steps are not strictly synched. 

Multi-node Tensorflow training is performed using multi-worker distributed training. For this, a TF_CONFIG configuration environment variable is needed for training on multiple nodes. For more on TF_CONFIG and distributed training, please refer to the official Tensorflow tutorials from where this example was borrowed: [Tensorflow/tutorial_distributed_training](https://www.tensorflow.org/tutorials/distribute/multi_worker_with_keras#multi-worker_configuration)

We use the `tf.distribute.MultiWorkerMirroredStrategy` API for our multi-node distributed tensorflow example. We set the TF_CONFIG configuration environment variable in our `submit.sbatch` script with two workers.
 
Submit the job with:
```
sbatch submit.sbatch
```

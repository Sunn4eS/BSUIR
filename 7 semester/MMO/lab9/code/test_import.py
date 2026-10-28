import tensorflow
print("TensorFlow version:", tensorflow.__version__)
try:
    from tensorflow.keras.datasets import imdb
    print("Successfully imported imdb dataset")
except ImportError as e:
    print("Import error:", e)

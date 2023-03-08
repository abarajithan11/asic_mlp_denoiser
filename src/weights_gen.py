import numpy as np

N1 = 98
N2 = 20
W_K = 1

w1 = np.random.randint(0, 2**W_K, N1*N2)
np.savetxt("weights_n1.mem", w1, fmt="%x")

w1 = np.random.randint(0, 2**W_K, N2)
np.savetxt("weights_n2.mem", w1, fmt="%x")
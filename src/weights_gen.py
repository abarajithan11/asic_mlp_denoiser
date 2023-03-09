import numpy as np
np.random.seed(0)

N1 = 98
N2 = 20
W_K = 4

w1_mag = np.random.randint(0, 2**W_K, (N1//2,N2))
w1_pol = np.random.randint(0, 2**W_K, (N1//2,N2))
# np.savetxt("weights_n1.mem", w1.flatten(), fmt="%x")

w2 = np.random.randint(0, 2**W_K, N2)
# np.savetxt("weights_n2.mem", w1, fmt="%x")

'''
WRITE WEIGHTS
'''

w1_mag_all = ""
for row in w1_mag:
  row_text = ""
  for e in row:
    row_text += f"{W_K}'d{e}".ljust(10) + ", "
  row_text = f"'{{ {row_text[:-2]} }}"
  w1_mag_all += f'''    {row_text},\n'''

w1_pol_all = ""
for row in w1_pol:
  row_text = ""
  for e in row:
    row_text += f"{W_K}'d{e}".ljust(10) + ", "
  row_text = f"'{{ {row_text[:-2]} }}"
  w1_pol_all += f'''    {row_text},\n'''

n2_row_text = ""
for e in row:
  n2_row_text += f"\n    {W_K}'d{e}".ljust(10) + ","

with open("weights_luts.sv", "w") as f:
  f.write(f'''

module weights_luts #(N1=98, N2=20, W_K=4)(
  output wire [W_K-1:0] weights_n1_mag [N1/2][N2],
  output wire [W_K-1:0] weights_n1_pol [N1/2][N2],
  output wire [W_K-1:0] weights_n2 [N2]
);
  assign weights_n1_mag = '{{
{w1_mag_all[:-2]}
  }};

  assign weights_n1_pol = '{{
{w1_pol_all[:-2]}
  }};

  assign weights_n2 = '{{{n2_row_text[:-1]}
  }};
endmodule
''')
# Assignment 2: Classify 
Detailed description of the project: https://hackmd.io/@sysprog/2024-arch-homework2

In this project, we’ll create a practical system using RISC-V assembly language, focusing on key low-level programming skills:

- Efficient register usage for optimized execution
- Writing functions that follow RISC-V calling conventions
- Managing memory with stack and heap allocation
- Manipulating pointers for matrix and vector operations

We’ll implement essential matrix and vector functions, like matrix multiplication, to build a simple Artificial Neural Network (ANN) capable of classifying handwritten digits, demonstrating how basic operations can power an ANN.

## Development Environment
- OS: Ubuntu 22.04 running on WSL2 
- Python: 3.12.2
- Required Software: https://hackmd.io/@sysprog/2024-arch-homework2#Install-required-software

## The Custom `mul` Function: `my_mul` 
This assignment is restricted to using RV32I commands. M-extension commands, such as `mul`, are not allowed. Instead, we replace `mul` with `my_mul`.

```assembly
# =======================================================
# FUNCTION: Integer Multiplication
#
# Performs operation: result = x * y
#
# Arguments:
#   Input Integers:
#     a0: First integer (x)
#     a1: Second integer (y)
#
# Output:
#   The result of x * y is stored in a0.
# =======================================================
my_mul:
    # Prologue
    addi sp, sp, -16
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw s3, 12(sp)

    mv s0, a0              # Multiplicand
    mv s1, a1              # Multiplier
    li s2, 0               # Result

multiply_loop:
    andi s3, s1, 1         # Check if the LSB of s1 is 1
    beq s3, zero, skip_add # If LSB is 0, skip addition
    add s2, s2, s0         # Add s0 to result

skip_add:
    slli s0, s0, 1         # Left shift s0 (multiplicand) by 1
    srli s1, s1, 1         # Right shift s1 (multiplier) by 1
    bnez s1, multiply_loop

end_multiply:
    mv a0, s2

    # Epilogue
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw s3, 12(sp)
    addi sp, sp, 16

    jr ra
```

Core Concept:
- Binary multiplication adds shifted versions of the multiplicand based on the multiplier's bits. 
- A bit of 1 means adding the shifted multiplicand; 0 means skipping.

High-Level Process:
- Decompose Multiplier: Check the LSB of the multiplier; if 1, add the shifted multiplicand to the result. Shift the multiplier right.
- Shift and Accumulate: Shift the multiplicand left (multiply by 2) and repeat until all multiplier bits are processed.

## Part A

### abs.s
This function first checks whether a value is positive or negative. If the value is negative, it converts it to positive by subtracting it from 0 and stores the result.
```assembly
abs:
    # ======================
    # This part is unchanged
    # ======================

    # TODO: Add your own implementation
    sub t0, zero, t0

```

### dot.s
This function computes the dot product of two vectors.
```assembly
dot:
    # ======================
    # This part is unchanged
    # ======================

    slli a3, a3, 2
    slli a4, a4, 2

loop_start:
    bge t1, a2, loop_end
    # TODO: Add your own implementation
    
    lw t2, 0(a0)
    lw t3, 0(a1)

    # Prologue
    addi sp, sp, -12
    sw ra, 0(sp)
    sw a0, 4(sp)
    sw a1, 8(sp)

    mv a0, t2
    mv a1, t3

    jal ra, my_mul
    add t0, t0, a0

    # Epilogue
    lw ra, 0(sp)
    lw a0, 4(sp)
    lw a1, 8(sp)
    addi sp, sp, 12

    add a0, a0, a3
    add a1, a1, a4

    addi t1, t1, 1
    j loop_start
```

### argmax.s
This function finds the index of the maximum value in a sequence. It starts by loading the value at the memory address pointed to by `a0` into `t3`. If `t3` is greater than the current maximum value in `t0`, it updates `t0` with the new maximum and stores the corresponding index in `t1`. The pointer `a0` is then incremented, and the index `t2` is updated before the loop repeats.
```assembly
argmax:
    # ======================
    # This part is unchanged
    # ======================

    addi a0, a0, 4

loop_start:
    # TODO: Add your own implementation
    beq t2, a1, done

    lw t3, 0(a0)

    bgt t3, t0, update_max  
    j index_increment 

update_max:
    mv t0, t3
    mv t1, t2

index_increment:
    addi a0, a0, 4
    addi t2, t2, 1
    j loop_start

```

### matmul.s
We made the following changes:
1. Add the missing part for incrementing the index in `inner_loop_end`
- `slli t0, a2, 2`: Shifts the column index to get the byte offset (4 bytes per element).
- `add s3, s3, t0`: Moves to the next row of matrix0.
- `addi s0, s0, 1`: Moves to the next column of matrix1.
2. Add the Prologue in `outer_loop_end`

```assembly
    # ======================
    # This part is unchanged
    # ======================

inner_loop_end:
    # TODO: Add your own implementation
    addi s0, s0, 1
    slli t0, a2, 2
    add s3, s3, t0
    j outer_loop_start

outer_loop_end:
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    lw s5, 24(sp)
    addi sp, sp, 28
    
    jr ra
```

### relu.s
This function works by checking if a value is negative. If the value is negative, it sets the value to 0. If the value is already 0 or positive, it remains unchanged.
```assembly
    # ======================
    # This part is unchanged
    # ======================

loop_start:
    beq t1, a1, done

    lw t3, 0(a0)

    blt t3, zero, set_zero
    j write

set_zero:
    li t3, 0 

write:
    sw t3, 0(a0) 

    addi a0, a0, 4 
    addi t1, t1, 1
    j loop_start
```
## Part B
In Part B, we use`my_mul` to replace `mul` in `classify.s`, `read_matrix.s`, and `write_matrix.s` Take one of the examples.

### classify.s
``` assembly
    # ======================
    # This part is unchanged
    # ======================

    # mul a1, t0, t1 # load length of array into second arg
    # FIXME: Replace 'mul' with your own implementation

    # Prologue
    addi sp, sp, -8
    sw ra, 0(sp)
    sw a0, 4(sp)

    mv a0, t0
    mv a1, t1

    jal ra, my_mul
    mv a1, a0

    # Epilogue
    lw ra, 0(sp)
    lw a0, 4(sp)
    addi sp, sp, 8
```


## The output of `./test.sh all` 
```
treeland@LAPTOP-IJA942DU:~/classify-rv32i$ ./test.sh all
test_abs_minus_one (__main__.TestAbs) ... ok
test_abs_one (__main__.TestAbs) ... ok
test_abs_zero (__main__.TestAbs) ... ok
test_argmax_invalid_n (__main__.TestArgmax) ... ok
test_argmax_length_1 (__main__.TestArgmax) ... ok
test_argmax_standard (__main__.TestArgmax) ... ok
test_chain_1 (__main__.TestChain) ... ok
test_classify_1_silent (__main__.TestClassify) ... ok
test_classify_2_print (__main__.TestClassify) ... ok
test_classify_3_print (__main__.TestClassify) ... ok
test_classify_fail_malloc (__main__.TestClassify) ... ok
test_classify_not_enough_args (__main__.TestClassify) ... ok
test_dot_length_1 (__main__.TestDot) ... ok
test_dot_length_error (__main__.TestDot) ... ok
test_dot_length_error2 (__main__.TestDot) ... ok
test_dot_standard (__main__.TestDot) ... ok
test_dot_stride (__main__.TestDot) ... ok
test_dot_stride_error1 (__main__.TestDot) ... ok
test_dot_stride_error2 (__main__.TestDot) ... ok
test_matmul_incorrect_check (__main__.TestMatmul) ... ok
test_matmul_length_1 (__main__.TestMatmul) ... ok
test_matmul_negative_dim_m0_x (__main__.TestMatmul) ... ok
test_matmul_negative_dim_m0_y (__main__.TestMatmul) ... ok
test_matmul_negative_dim_m1_x (__main__.TestMatmul) ... ok
test_matmul_negative_dim_m1_y (__main__.TestMatmul) ... ok
test_matmul_nonsquare_1 (__main__.TestMatmul) ... ok
test_matmul_nonsquare_2 (__main__.TestMatmul) ... ok
test_matmul_nonsquare_outer_dims (__main__.TestMatmul) ... ok
test_matmul_square (__main__.TestMatmul) ... ok
test_matmul_unmatched_dims (__main__.TestMatmul) ... ok
test_matmul_zero_dim_m0 (__main__.TestMatmul) ... ok
test_matmul_zero_dim_m1 (__main__.TestMatmul) ... ok
test_read_1 (__main__.TestReadMatrix) ... ok
test_read_2 (__main__.TestReadMatrix) ... ok
test_read_3 (__main__.TestReadMatrix) ... ok
test_read_fail_fclose (__main__.TestReadMatrix) ... ok
test_read_fail_fopen (__main__.TestReadMatrix) ... ok
test_read_fail_fread (__main__.TestReadMatrix) ... ok
test_read_fail_malloc (__main__.TestReadMatrix) ... ok
test_relu_invalid_n (__main__.TestRelu) ... ok
test_relu_length_1 (__main__.TestRelu) ... ok
test_relu_standard (__main__.TestRelu) ... ok
test_write_1 (__main__.TestWriteMatrix) ... ok
test_write_fail_fclose (__main__.TestWriteMatrix) ... ok
test_write_fail_fopen (__main__.TestWriteMatrix) ... ok
test_write_fail_fwrite (__main__.TestWriteMatrix) ... ok

----------------------------------------------------------------------
Ran 46 tests in 109.711s

OK
```
.globl dot

.text
# =======================================================
# FUNCTION: Strided Dot Product Calculator
#
# Calculates sum(arr0[i * stride0] * arr1[i * stride1])
# where i ranges from 0 to (element_count - 1)
#
# Args:
#   a0 (int *): Pointer to first input array
#   a1 (int *): Pointer to second input array
#   a2 (int):   Number of elements to process
#   a3 (int):   Skip distance in first array
#   a4 (int):   Skip distance in second array
#
# Returns:
#   a0 (int):   Resulting dot product value
#
# Preconditions:
#   - Element count must be positive (>= 1)
#   - Both strides must be positive (>= 1)
#
# Error Handling:
#   - Exits with code 36 if element count < 1
#   - Exits with code 37 if any stride < 1
# =======================================================
dot:
    li t0, 1
    blt a2, t0, error_terminate  
    blt a3, t0, error_terminate   
    blt a4, t0, error_terminate  

    li t0, 0
    li t1, 0 

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

loop_end:
    mv a0, t0
    jr ra

error_terminate:
    blt a2, t0, set_error_36
    li a0, 37
    j exit

set_error_36:
    li a0, 36
    j exit

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
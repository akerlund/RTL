# CORDIC - System Verilog

![Build Status](https://img.shields.io/badge/build-passes-lightgrey)
![Test  Status](https://img.shields.io/badge/test-N/A-lightgrey)
![Synth Status](https://img.shields.io/badge/synthesis-passes-lightgrey)
![FPGA  Status](https://img.shields.io/badge/fpga-passes-lightgrey)

I rewrote an old CORDIC I did in school to this. While at it I attempted to write down the algorithm for finding the angles of arctan in a Python script.

It needs a test bench and some documentation.

## CORDIC Theory

The CORDIC (COordinate Rotation Digital Computer) algorithm was developed by Jack Volder in 1959[1, 2] to calculate trigonometric functions, i.e., sine and cosine. Its advantage when implemented in hardware is that, as an iterative algorithm, it only uses shift, add and subtract operations to convert between polar and Cartesian coordinates. In circular rotation mode the Cartesian coordinates of the vector V$_{0}$ can be found by rotating an input vector V$_{n}$ by an angle $\Theta$ = Z$_{0}$ towards the desired angle. The range of rotation differs from stage to stage and is described as

(Eq. 1)          $\tan(\Theta)$ = ±$2^{-i}$, *i* $\geq$ 0


where *i* denotes the stage number. The idea is that the values from the above equation are saved in a look-up table (LUT) and are used as the angles for rotating the input vector around the desired vector. Every rotation around or towards the desired angle will increase the accuracy of the approximation of the desired angle's vector as it will get closer every iteration.

![alt text](https://github.com/akerlund/rtl_common_design/blob/master/math/cordic/cordic-vectors.png)

*Figure 1. Simplified example of an input vector used to approximate another.*

Recall that any vector like V$_{n}$ = [X$_{n}$ Y$_{n}$], illustrated in Fig. 1, can be described as in


(Eq. 2)          $X_n$ = $X_0$ $\cos(\Theta)$ - $Y_0$ $\sin(\Theta)$ = $\cos(\Theta)$[$X_0$ - $Y_0$ $\tan(\Theta)$]

and

(Eq. 3)          $Y_n$ = $Y_0$ $\cos(\Theta)$ + $X_0$ $\sin(\Theta)$ = $\cos(\Theta)$[$Y_0$ + $X_0$ $\tan(\Theta)$].

These equations include some trigonometric operations which will be reduced step by step. The *sin* term can be removed by dividing the expression with *cos* which in turn yields a new expression with only *cos* and *tan* terms. The first step towards further simplification is to consider if the tangent function is restricted as in (1), which essentially describes a shift operation. Deriving the first values from this method yields:

$\tan(\Theta)$ = ±$2^{0}$, $2^{-1}$, $2^{-2}$, $2^{-3}$, ..., $2^{-i}$ = ±1, $\frac{1}{2}$, $\frac{1}{4}$, $\frac{1}{8}$, ..., $\frac{1}{i}$

Further calculations for the respective angles of the function are shown in Table 1.

The desired angle can be found by iterative rotations of the input vector with the angles in Table 1. An infinite amount of rotations would allow the result to converge at the exact angle.

| *i* | atan(2$^{-i}$) | $\Theta$ |
| -   | :-             |       -: |
| 0   | atan(1)        | 45       |
| 1   | atan(1/2)      | 26.565   |
| 2   | atan(1/4)      | 14.036   |
| 3   | atan(1/8)      | 7.125    |
| 4   | atan(1/16)     | 3.576    |
| 5   | atan(1/32)     | 1.789    |
| 6   | atan(1/64)     | 0.895    |
| 7   | atan(1/128)    | 0.448    |
| 8   | atan(1/256)    | 0.224    |
| 9   | atan(1/512)    | 0.112    |

*Table 1. Possible angles of atan(2$^{-i}$).*

An example of rotation is shown in Table 2. The desired angle in the Table is Z$_{0}$ = 20°, and this angle will be set as the input vector for the first stage. At the first iteration the angle's sign is compared, and if positive, Z$_{0}$ $\geq$ 0, it would then be subtracted by the respective value in the tangent look-up table. Then, in the following iteration the input vector is now -25° and will again be compared. This time it is negative, so the respective look-up table value will be added to it and Z$_{2}$ = 1.565°. The pattern should now be clear; at each iteration it is decided in which direction to rotate. Table 1 shows that the remaining angle converges to zero. The valid input angles are between

$\pi$/2~$\leq$~$\Theta$~$\leq$~$\pi$/2

so if the angle of the input vector is not in the first or fourth quadrant it can simply be rotated by $±$~$\pi$/2.

Iteration | Angle  | tan($\Theta$) | Result                   |
| -       | :-     |       -:      |                       -: |
| 0       | 45     | 1             | 20 - 45 = -25            |
| 1       | 26.565 | 1/2           | -25 + 26.565 = 1.565     |
| 2       | 14.036 | 1/4           | 1.565 - 14.036 = -12.471 |
| 3       | 7.125  | 1/8           | -12.471 + 7.125 = -5.346 |
| 4       | 3.576  | 1/16          | -5.346 + 3.576 = -1.77   |
| 5       | 1.79   | 1/32          | -1.77 + 1.79 = 0.02      |
| 6       | 0.895  | 1/64          | 0.02 - 0.895 = -0.875    |
| 7       | 0.448  | 1/128         | -0875 + 0.448 = -0.427   |
| ...     | ...    | ...           | ..                       |
*Table 2. Possible angles of atan(2$^{-i}$).*

This means that the iterations of the input vector of the different stages are described in

(Eq. 4)          $Z_{i+1}$ = $Z_{i}$ - $d_{i}$$\tan^{-1}(2^{-i})$, $d_{i}$ = ± 1,

where $d_{i}$ represent the rotating direction by the comparison of Z$_{i}$ $\geq$ 0 for the $i^{th}$ stage. In other words, the angular accumulator decides the direction $d_{i}$ in each iteration. It should also be clear that since the values are shifted at each iteration it is not necessary, or possible, to perform more of them than the width of the words used to store the values.

The expressions for all vectors V$_{i+1}$ in stages after the first *i = 0*, can be formulated as in

(Eq. 5)          $X_{i+1} = K_{i}[X_{i} - Y_{i}d_{i}2^{-i}],~d_{i} = ± 1$

and

(Eq. 6)          $X_{i+1} = K_{i}[X_{i} - Y_{i}d_{i}2^{-i}],~d_{i} = ± 1$

where the *$\cos(\Theta)$* term in front of (1) and (3) is denoted as ${K_{i}}$ instead. The vector $V_{i+1}$ is shifted right once by the term ($2^{-i}$) and also depends on the evaluation of the input angle.

Since $cos(\Theta) = cos(-\Theta)$ *$K_{i}$* does not depend on the direction of rotation. Thus, it can be expressed as

(Eq. 7)          A_$K_{i} = cos(\Theta) = cos(tan^{-1}(2^{-i})) = \frac{1}{\sqrt{1+2^{-2i}}}$.

$K_{i}$ is a constant and can be considered to be the gain of the CORDIC stage.

The total gain $A_{i}$ of all *i* stages is the sum of their products in

(Eq. 8)          $A_{i} = \prod_{n}^{i-1} \frac{1}{\sqrt{1+2^{-2n}}}.$


With an infinite amount of stages the acquired value of an angle will be exact, and the total gain will converge to

(Eq. 9)          $\lim_{i\to\infty} A_{i} \approx 1.646760258.$

Table 3 shows the gain $A_{i}$ of the 16 first stages. Only the first few stages show a lot of variation; after the fifth stage the gain has an accuracy up to three decimal places.

| *i* | $A_{i}$        |
| -   | :-             |
| 0   | 1.414213562373 |
| 1   | 1.581138830084 |
| 2   | 1.629800601301 |
| 3   | 1.642484065752 |
| 4   | 1.645688915757 |
| 5   | 1.646492278712 |
| 6   | 1.646693254274 |
| 7   | 1.646743506597 |
| 8   | 1.646756070205 |
| 9   | 1.646759211140 |
| 10  | 1.646759996376 |
| 11  | 1.646760192685 |
| 12  | 1.646760241762 |
| 13  | 1.646760254031 |
| 14  | 1.646760257099 |
| 15  | 1.646760257865 |
*Table 3. The first values of A$_{i}$.*




### References
[1] Jack E Volder. The cordic trigonometric computing technique.Electronic Computers, IRE Transactionson, (3):330-334, 1959.

[2] Dirk  Koch. Cordic algorithm, 2012. Available at http://www.uio.no/studier/emner/matnat/ifi/INF5430/v12/undervisningsmateriale/dirk/Lecture_cordic.pdf.

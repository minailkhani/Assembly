# Some basic practical homework (in order of difficulty)


## BCD-to-binary:
Convert the given 3 digit BDC(Binary-coded decimal) to binary.
#### test case:
input: \
010000011000 \
output: \
110100010 


## digitAdd-E-O:
Calculate the summation of the odd and even digits of the given number separately.
#### test case:
input: \
138 \
output: \
4 8 


## digitAdd:
Calculate the summation of the digits of the given number.
#### test case:
input:
99 \
output:
18 


## greatest common divisor:
Finding greatest common divisor of two given numbers.
#### test case: 
input: \
136 \
96 \
output: \
8 


## least common factor:
Finding least common factor of two given numbers. 
#### test case:
input: \
 16 \
 14 \
output: \
112


## perfect number:
Check if the given number is perfect or not and print its factors. \
A number is perfect if and only if the summation of its divisors equals the number.
#### test case:
input1: \
28 \
output1: \
Perfect \
1 2 4 7 14 \
input2: \
56 \
output2: \
Nope \
1 2 4 7 8 14 28


## prime number:
Check if the given number is prime.
#### test case:
input: \
13 \
output: \
Yes

# Every number is greater than 1 and less than $3\times 10 ^{7}$  in the projects above.

--------------------------------------------------------------------------------------------------------

## count-one-m:
Two numbers and a string are given. Count the 1s in the memory in which s is located from the index of the first number to the index of the second number.

![image](https://user-images.githubusercontent.com/83788223/208285470-53cc9127-0afd-42f4-83bb-22914d955e50.png)

#### test case:
input: \
2
4
salAm
output: \
11 \
(salAm -> 01110011 01100001 0**11**0**11**00 0**1**00000**1** 0**11**0**11**0**1**)


## count-one:
Calculate the summation of ones in binary form of the given decimal number.
#### test case:
input: \
8724222251 \
output: \
9
(bin(8724222251): **1**00000**1**0000000000**1**000**1**000**1**00**1**0**1**0**11**)


## reverseBit:
Print reverse of the binary form of the given decimal number.(in rax)
#### test case:
input: \
5 \
output: \
1010000000000000000000000000000000000000000000000000000000000000

--------------------------------------------------------------------------------------------------------
## binary search:
What is binary search? https://www.geeksforgeeks.org/binary-search/

## quick sort:
What is quick sort ? https://www.geeksforgeeks.org/quick-sort/

(stack is used in 2 above projects)

--------------------------------------------------------------------------------------------------------

## min dif floating point:
Number n and n floating point numbers are given. print two floating point number with minimum difference
#### test case:
input: \
5 \
1.123 \
4.56735 \
5.999999 \
6.1 \
7.345 \
output: \5.999999 6.100000

## seri floating point:
Calculate seri below: \

<img src="https://latex.codecogs.com/svg.latex?\Large&space;f(n,x)&space;=&space;\sum_{k=0}^{n}((1/k!)x^{k})" />)

--------------------------------------------------------------------------------------------------------

## ‫‪lightImages‬‬
Path to a folder and number n is given. make the images in the path n degrees brighter **parallelly** if its format is .bmp(Windows or OS/2 and 24bit). create a folder which is named edited_photo in that path and save new images in edited_photo.

#### examlpe:
n = 200
![image](https://user-images.githubusercontent.com/83788223/208288056-8ee3e833-dd2c-4bdb-a082-8d8363102228.png)

The test case is in light_image folder. path is path_to_dir and n is equal to 200.

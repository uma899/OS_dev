# What's new?
There is a linker. What it is? Idk
But, the final compilation is such that all object files are attached. So, the kernel.asm can call the 
main function of C. From then, what instructions in kernel.c are executed. As while (1) is written, it
cant come out of that C code to assembly.

We can now write in C. Access hardware ports from C!

**How?**
See io.asm file. Same names used in kernel.c. As we call that function with some parameters in, it places
that variable on stack and then call that function. That function in assembly does something and put 
result in ax (eax) register. It is a convention in C that return value must be in eax and functional 
arguments to be pushed onto stack.

And, keyboard handler, which used to be in assembly in previous version, now written in C and its address 
(just label) is given to isr. So from now, all interrupt handers can be written in C but they should be 
informed to isr so it can know where to jump.


# What it can do 
You can write, press enter, scroll down (but not up).


# Whats next?
Trying to use direct pixels to display!



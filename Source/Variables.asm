; Simple stack setup
StackSpace:                 DS      256             ; 256 bytes for stack, may need a bit more with some of the stack use in the test pack.
                            DS      256
StackTop:                   DS      2               ; Storage for stack top pointer
OriginalStack:              DS      2               ; Storage for original stack pointer

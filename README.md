# Occ_Aware
This code is based on the paper "Occlusion-Aware Fragment-Based Tracking With Spatial-Temporal Consistency". If you find our paper useful, please consider to cite our paper:   
@article{sun2016occlusion,  
  title={Occlusion-Aware Fragment-Based Tracking With Spatial-Temporal Consistency},  
  author={Sun, Chong and Wang, Dong and Lu, Huchuan},  
  journal={IEEE Transactions on Image Processing},  
  volume={25},  
  number={8},  
  pages={3814--3825},  
  year={2016}  
}  

------------
Requirements
------------
This code has been developed and tested with Windows 7, Matlab R2012b (64-bit). To compute the optical flow, users need to make sure that OpenCV 2.4.10 is installed. 

-----
Usage
-----
Users can directly run "benchmark_function.m" to test the code. In addition, we set the default path for the video sequences in "D:\data_seq\", users can edit "benchmark\configSeqs.m" to revise the path and choose the videos that you want to test. 

-----
Notice
-----
We write this code without optimization, and several modifications can be added to the code to make it run faster, e.g., we can parallelize the code in the feature extraction and model updating process, which will greatly saves the computation time.

-----
Liscense
-----
Copyright (c) 2016, Chong Sun  
All rights reserved.  
Redistribution and use in source and binary forms, with or without modification, are 
    permitted provided that the following conditions are met:
        * Redistributions of source code must retain the above copyright 
          notice, this list of conditions and the following disclaimer.
        * Redistributions in binary form must reproduce the above copyright 
          notice, this list of conditions and the following disclaimer in 
          the documentation and/or other materials provided with the distribution

    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
    AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
    IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
    ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE    
    LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
    CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
    SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
    INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
    CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
    ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
    POSSIBILITY OF SUCH DAMAGE.

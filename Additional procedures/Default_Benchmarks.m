%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     
%     CMOST: Colon Modeling with Open Source Tool
%     created by Meher Prakash and Benjamin Misselwitz 2012 - 2016
%
%     This program is part of free software package CMOST for colo-rectal  
%     cancer simulations: You can redistribute it and/or modify 
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
% 
%       
%     This program is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
% 
%     You should have received a copy of the GNU General Public License
%     along with this program.  If not, see <http://www.gnu.org/licenses/>.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function handles = Default_Benchmarks(handles)



% Overall (总体)
% 原始: [3.74, 6.25, 8.09, 11.79, 13.73, 14.69, 19.32]% @ [35,42,47,52,57,62,70]
% pchip外推: 25→-0.94 (负值需约束)
% 应用生物学约束后: 25→0.10
handles.Variables.Benchmarks.EarlyPolyp.Ov_y          = [35 42 47 52 57 62 70];
handles.Variables.Benchmarks.EarlyPolyp.Ov_perc       = [3.74 6.25 8.09 11.79 13.73 14.69 19.32];

% Male (男性)
% 原始(修正后): [4.22, 6.98, 9.70, 14.48, 15.76, 17.03, 20.72]% @ [35,42,47,52,57,62,70]
% pchip外推: 25→-0.63 (负值需约束)
% 应用生物学约束后: 25→0.10
handles.Variables.Benchmarks.EarlyPolyp.Male_y        = [35 42 47 52 57 62 70];
% handles.Variables.Benchmarks.EarlyPolyp.Male_perc     = [4.22 6.98 9.70 14.48 15.76 17.03 20.72];
handles.Variables.Benchmarks.EarlyPolyp.Male_perc     = [4.22 6.98 9.70 14.48 17.98 17.03 20.72];

% Female (女性)
% 原始(修正后): [2.88, 5.40, 6.03, 8.21, 9.94, 11.67, 17.41]% @ [35,42,47,52,57,62,70]
% pchip外推: 25→-1.53 (负值需约束)
% 应用生物学约束后: 25→0.10
handles.Variables.Benchmarks.EarlyPolyp.Female_y      = [35 42 47 52 57 62 70];
% handles.Variables.Benchmarks.EarlyPolyp.Female_perc   = [2.88 5.40 6.03 8.21 9.94 11.67 17.41];
handles.Variables.Benchmarks.EarlyPolyp.Female_perc   = [2.88 5.40 6.03 8.21 8.20 11.67 17.41];


% Multiple Polyps (多发腺瘤分布)
% 温州数据
% handles.Variables.Benchmarks.MultiplePolyp            = [65.76 8.56 8.56 8.56 8.56];
handles.Variables.Benchmarks.MultiplePolyp            = [36 16 5 4 3];
handles.Variables.Benchmarks.MultiplePolypsYoung = [18 5  3  3 2];
handles.Variables.Benchmarks.MultiplePolypsOld   = [40 24 10 8 4];

% Advanced Adenoma (进展期腺瘤) - 温州数据
% 原始数据年龄段: <39, 40-44, 45-49, 50-54, 55-59, 60-64, ≥65
% 转换为中点年龄: 35, 42, 47, 52, 57, 62, 70

% Overall (总体)
% 原始: [0.86, 1.95, 2.51, 4.01, 4.57, 6.01, 7.98]%
handles.Variables.Benchmarks.AdvPolyp.Ov_y          = [35 42 47 52 57 62 70];
handles.Variables.Benchmarks.AdvPolyp.Ov_perc       = [0.86 1.95 2.51 4.01 4.57 6.01 7.98];

% Male (男性)
% 原始: [0.88, 2.62, 3.40, 5.12, 6.12, 7.17, 9.08]%
handles.Variables.Benchmarks.AdvPolyp.Male_y        = [35 42 47 52 57 62 70];
handles.Variables.Benchmarks.AdvPolyp.Male_perc     = [0.88 2.62 3.40 5.12 6.12 7.17 9.08];

% Female (女性)
% 原始: [0.82, 1.20, 1.37, 2.59, 2.60, 4.53, 6.39]%
handles.Variables.Benchmarks.AdvPolyp.Female_y      = [35 42 47 52 57 62 70];
% handles.Variables.Benchmarks.AdvPolyp.Female_perc   = [0.82 1.20 1.37 2.59 3.56 4.53 6.39];
handles.Variables.Benchmarks.AdvPolyp.Female_perc   = [0.82 1.20 1.37 2.59 2.60 4.53 6.39];


% Distribution of Polyp Size (腺瘤大小分布)
handles.Variables.Benchmarks.Polyp_Distr            = [34.95 27 21 7.9 7.3 1.85];

% Cancer (癌症发病率) - 中国GBD数据
% 年龄段: 1.5, 5.5, 12, 17, 22, 27, 32, 37, 42, 47, 52, 57, 62, 67, 72, 77, 82, 87
handles.Variables.Benchmarks.Cancer.Ov_y          = [17  22  27  32  37  42  47  52  57  62  67  72  77  82  87  92  97];
handles.Variables.Benchmarks.Cancer.Ov_inc        = [0.75 1.69 3.78 8.11 12.86 20.77 28.25 46.9  67.47 98.8  135.96 194.76 238.81 256.51 314.59 255.52 192.31];
handles.Variables.Benchmarks.Cancer.Male_y        = [17  22  27  32  37  42  47  52  57  62  67  72  77  82  87  92  97];
handles.Variables.Benchmarks.Cancer.Male_inc      = [0.94 2.17 5.07 11.42 18.22 28.79 38.92 62.38 89.06 127.29 173.44 246.88 310.23 343.37 510.58 471.32 316.17];
handles.Variables.Benchmarks.Cancer.Female_y      = [17  22  27  32  37  42  47  52  57  62  67  72  77  82  87  92  97];
handles.Variables.Benchmarks.Cancer.Female_inc    = [0.53 1.14 2.35 4.56 7.2  12.23 17.23 31.05 45.96 70.12 99.66 145.65 175.19 188.73 201.72 173.31 163.4];
% handles.Variables.Benchmarks.Cancer.Ov_y          = [1.5 5.5 12 17  22  27  32  37  42  47  52  57  62  67  72  77  82];
% handles.Variables.Benchmarks.Cancer.Ov_inc        = [0 0 0 0.75 1.69 3.78 8.11 12.86 20.77 28.25 46.9  67.47 98.8  135.96 194.76 238.81 256.51];
% handles.Variables.Benchmarks.Cancer.Male_y        = [1.5 5.5 12 17  22  27  32  37  42  47  52  57  62  67  72  77  82];
% handles.Variables.Benchmarks.Cancer.Male_inc      = [0 0 0 0.94 2.17 5.07 11.42 18.22 28.79 38.92 62.38 89.06 127.29 173.44 246.88 310.23 343.37];
% handles.Variables.Benchmarks.Cancer.Female_y      = [1.5 5.5 12 17  22  27  32  37  42  47  52  57  62  67  72  77  82];
% handles.Variables.Benchmarks.Cancer.Female_inc    = [0 0 0 0.53 1.14 2.35 4.56 7.2  12.23 17.23 31.05 45.96 70.12 99.66 145.65 175.19 188.73];
% handles.Variables.Benchmarks.RMS.Cancer           = 30;

% relative danger polyps (相对危险度)
handles.Variables.Benchmarks.Rel_Danger           = [18.7  23.8  25.0  29.0  30.0  32.0];
% handles.Variables.Benchmarks.Rel_Danger           = [0.07  0.07  0.42  0.42  13.23  85.8];


% fraction rectum carcinoma
% handles.Variables.Benchmarks.Cancer.LocationRectumMale   = [41.2     34.1      28.6     23.8];
% handles.Variables.Benchmarks.Cancer.LocationRectumFemale = [37.2     28.3      23.0     19.0];
% handles.Variables.Benchmarks.Cancer.LocationRectumYear   = {[51 55], [61 65], [71 75], [81 85]};  % year adapted
handles.Variables.Benchmarks.Cancer.LocationRectumMale   = [47.2     51.0      48.5     42.4];
handles.Variables.Benchmarks.Cancer.LocationRectumFemale = [46.7     45.7      39.8     36.7];
handles.Variables.Benchmarks.Cancer.LocationRectumYear   = {[41 45], [51 55], [61 65], [71 75]};  % year adapted
                                                          % age 52,   62     72        82.

% rectosigmoidoscopy study
% according to Atkin et al., Lancet 2010
handles.Variables.Benchmarks.RSRCTRef.IncRedOverall = 21;

% cancer mortality
% SEER 2000 - 2009 change to GBD China2021
% handles.Variables.Benchmarks.Cancer.Ov_y_mort  = [1.5  5.5     12    17      22      27      32      37      42      47      52      57      62      67      72      77      82       87];
% handles.Variables.Benchmarks.Cancer.Ov_mort     = [0   0   0    0.0529  0.1655  0.4638  0.9891  2.0413  3.975   7.777   13.83   22.59   35.925  54.36   78.43   108.39  150.077  228.69];
% handles.Variables.Benchmarks.Cancer.Male_mort   = [0   0   0    0.064   0.1897  0.5012  1.0565  2.2269  4.3208  8.6845  16.1    27.34   44.515  68.54   97.71   133.57  182.49   266.34];
% handles.Variables.Benchmarks.Cancer.Female_mort = [0   0   0    0.0412  0.14    0.425   0.9203  1.8546  3.6327  6.8927  11.67   18.13   28.085  42.01   62.81   90.097  129.93   212.28];
handles.Variables.Benchmarks.Cancer.Ov_y_mort      = [1.5  5.5   12 17  22  27  32  37  42  47  52  57  62  67  72  77  82  87];
handles.Variables.Benchmarks.Cancer.Ov_mort       = [0   0   0   0.25 0.56 1.14 2.38 3.99 6.37 9.02 14.74 22.12 34.31 50.48 80.87 116.92 259.79 230.31];
handles.Variables.Benchmarks.Cancer.Male_mort     = [0   0   0   0.32 0.75 1.56 3.45 5.77 9.04 12.73 20.09 29.8  44.97 65.34 103.68 152.82 214.68 375.64];
handles.Variables.Benchmarks.Cancer.Female_mort   = [0   0   0   0.16 0.35 0.66 1.24 2.1  3.57 5.19  9.26  14.47 23.59 36.08 59.39 84.94 116.95 146.63];


% some additional variables
handles.Variables.DirectCancerRate(1,1:20)    = [0,0, 0, 0,     0.6,    1.5,    3.3,    6.6,    12.9,   25,     48,     77,     110,    162.5,  223.75, 280.6,  335.5,  379.1  395.4, 395.4];
handles.Variables.DirectCancerRate(2,1:20)    = [0,0, 0, 0,     0.6,    1.5,    3.2,    6.3,    12.1,   21.2,   38.5,   56.9,   75,     109.1,  152.5,  201.1,  255.35, 300.85 319.5, 319.5];
handles.Variables.Location_DirectCa           = [0.9985,  0.9959, 0.989, 0.9707, 0.9241, 0.8176, 0.6225, 0.3775, 0.1824, 0.0759, 0.0293, 0.011, 0.0041];

% some hacks
handles.Variables.Cost.Colonoscopy_Cancer   = 0;
handles.Variables.MaxIterations    = 20;

% P1, P2, P3, P4, P5, P6, Ca1, Ca2, Ca3, Ca4 
handles.Variables.Screening.FOBT_Sens         = [0.02,  0.02,  0.05,  0.05,  0.12,  0.12,  0.4,  0.4,  0.4,  0.4];
handles.Variables.Screening.I_FOBT_Sens       = [0.05,  0.05,  0.101, 0.101, 0.22,  0.22,  0.7,  0.7,  0.7,  0.7];
handles.Variables.Screening.Sept9_HiSens_Sens = [0,     0,     0,     0,     0,     0,     0.89, 0.93, 0.99, 0.99];
handles.Variables.Screening.Sept9_HiSpec_Sens = [0,     0,     0,     0,     0,     0,     0.67, 0.86, 0.87, 0.82];
handles.Variables.Screening.other_Sens        = [0.075, 0.075, 0.124, 0.124, 0.239, 0.239, 0.7,  0.7,  0.7,  0.7];
% numbers quoted from zauber, annals 2008. 

% screening settings
handles.Variables.Screening.Colonoscopy = [0,... Follow up is missing, specificity pointless
    0.75,      50, 81, 10, 5, 0];
handles.Variables.Screening.Rectosigmoidoscopy = [0,... specificity pointless
    0.75, 0.9, 50, 81, 5, 5, 0];
handles.Variables.Screening.FOBT = [0,...
    0.5,  0.9, 50, 81, 1, 5, 0.98];
handles.Variables.Screening.I_FOBT = [0,...
    0.5,  0.9, 50, 81, 1, 5, 0.95];
handles.Variables.Screening.Sept9_HiSens = [0,...
    0.9,  0.9, 50, 81, 1, 5, 0.85];
handles.Variables.Screening.Sept9_HiSpec = [0,...
    0.9,  0.9, 50, 81, 1, 5, 0.99];
handles.Variables.Screening.other = [0,...
    0,    0,   50, 81, 1, 5, 0.925];

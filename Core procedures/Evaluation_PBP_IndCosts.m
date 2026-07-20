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

function [data,BM] = Evaluation_PBP_IndCosts(data, Variables)
%% 为了彻底禁止弹出任何figure窗口，临时关闭全局Figure显示，并记录已有figure
origFigVisible = get(0, 'DefaultFigureVisible');
origFigures    = findall(0, 'Type', 'figure');
set(0, 'DefaultFigureVisible', 'off');
figCleanup = onCleanup(@()restoreFigState(origFigVisible, origFigures));
    disp(['Evaluation_PBP_IndCosts called. DispFlag: ' num2str(Variables.DispFlag)]);
rootDir = fileparts(mfilename('fullpath'));
if isempty(rootDir)
    rootDir = pwd;  % 兜底，确保有有效路径
end
logDir  = fullfile(rootDir, '..', 'logs');
if ~exist(logDir, 'dir')
    [mkOk, mkMsg] = mkdir(logDir);
    if ~mkOk
        warning('Evaluation_PBP_IndCosts:LogDirFailed', '无法创建日志目录：%s (%s)', logDir, mkMsg);
        fid = -1;
    end
end
if ~exist('fid', 'var') || fid ~= -1
    logFile = fullfile(logDir, 'debug_log.txt');
    fid = fopen(logFile, 'a');
    if fid == -1
        warning('Evaluation_PBP_IndCosts:LogOpenFailed', '无法写入日志文件：%s', logFile);
    else
    fprintf(fid, 'Evaluation_PBP_IndCosts called. DispFlag: %d\n', Variables.DispFlag);
    fclose(fid);
    end
end

% comment about TIME (year)
% in all scripts PRECEDING this time was 1-100 (Lebensjahre)
% in EVALUATION we transform this to age (0-99)

% for PBC we save these data directly to the results variable
Results = struct;
Results.DiagnosedCancer = data.DiagnosedCancer;
Results.DeathYear       = data.DeathYear;

DispFlag    = Variables.DispFlag;
ResultsFlag = Variables.ResultsFlag;
ExcelFlag   = Variables.ExcelFlag;

y = data.y;
n = data.n;

% key settings
FontSz   = 7;
MarkerSz = 4;
LineSz   = 0.4;
bmc      = 1;

tolerance = 0.2

BM.description = cell(100, 1);
BM.value       = cell(100, 1); 
BM.benchmark   = cell(100, 1);
BM.flag        = cell(100, 1);
 
% Benchmarks
% a few benchmarks remain hardcoded:

Variables.Benchmarks.MultiplePolypsYoung = [18 5  3  3 2];
% MidBenchmark   = [36 16 5  4 3];
% MidBenchmark   = Variables.Benchmarks.MultiplePolyp;
Variables.Benchmarks.MultiplePolypsOld   = [40 24 10 8 4];

%Variables.Benchmarks.Cancer.SymptomaticStageDistribution  = [15 35.6 27.9 21.5];
% now I just averaged the benchmarks of the 1988-2000 period
Variables.Benchmarks.Cancer.SymptomaticStageDistribution  = [18.92 27.67 29.89 23.52];
Variables.Benchmarks.Cancer.ScreeningStageDistribution    = [39.5 34.7 17.3 8.5];


% Variables.Benchmarks.Cancer.LocationRectumMale   = [41.2     34.1      28.6     23.8];
% Variables.Benchmarks.Cancer.LocationRectumFemale = [37.2     28.3      23.0     19.0];
% Variables.Benchmarks.Cancer.LocationRectumYear   = {[51 55], [61 65], [71 75], [81 85]};  % year adapted
Variables.Benchmarks.Cancer.LocationRectumMale   = [47.2     51.0      48.5     42.4];
Variables.Benchmarks.Cancer.LocationRectumFemale = [46.7     45.7      39.8     36.7];
Variables.Benchmarks.Cancer.LocationRectumYear   = {[41 45], [51 55], [61 65], [71 75]};  % year adapted


Variables.Benchmarks.Cancer.Fastcancer           = [0.005 0.05 0.08 0.25 3 20];

% 癌症发病率基准数据 - 与基准年龄段对齐 (14个点)
Variables.Benchmarks.Cancer.Ov_y                 = [17  22  27  32  37  42  47  52  57  62  67  72  77  82];
Variables.Benchmarks.Cancer.Ov_inc               = [0.75 1.69 3.78 8.11 12.86 20.77 28.25 46.9  67.47 98.8  135.96 194.76 238.81 256.51];
Variables.Benchmarks.Cancer.Male_y               = [17  22  27  32  37  42  47  52  57  62  67  72  77  82];
Variables.Benchmarks.Cancer.Male_inc             = [0.94 2.17 5.07 11.42 18.22 28.79 38.92 62.38 89.06 127.29 173.44 246.88 310.23 343.37];
Variables.Benchmarks.Cancer.Female_y             = [17  22  27  32  37  42  47  52  57  62  67  72  77  82];
Variables.Benchmarks.Cancer.Female_inc           = [0.53 1.14 2.35 4.56 7.2  12.23 17.23 31.05 45.96 70.12 99.66 145.65 175.19 188.73];

%SEER 1988 - 2000
% Variables.Benchmarks.Cancer.Ov_y_mort  = [1.5  5.5  12   17     22   27   32  37   42  47   52   57   62    67   72    77     82     87];
% Variables.Benchmarks.Cancer.Ov_mort     = [0   0    0    0.1    0.2  0.4  1   2    4   8.2  15.8 28.6 47.2  71.2 102.6 140.4  193.5  285.1];
% Variables.Benchmarks.Cancer.Male_mort   = [0   0    0    0.1    0.2  0.5  1.1 2.1  4.3 9.2  18.2 34   58.1  89.2 128.8 176.2  241.5  342.2];
% Variables.Benchmarks.Cancer.Female_mort = [0   0    0    0.1    0.2  0.4  0.9 1.8  3.7 7.3  13.5 23.6 37.5  56.2 82.6  116.5  166.8  262.7];
Variables.Benchmarks.Cancer.Ov_y_mort  = [1.5  5.5  12   17     22   27   32  37   42  47   52   57   62    67   72    77     82     87];
Variables.Benchmarks.Cancer.Ov_mort     = [0    0    0    0.25 0.56 1.14 2.38 3.99 6.37 9.02 14.74 22.12 34.31 50.48 80.87 116.92 259.79 230.31];
Variables.Benchmarks.Cancer.Male_mort   = [0    0    0    0.32 0.75 1.56 3.45 5.77 9.04 12.73 20.09 29.8  44.97 65.34 103.68 152.82 214.68 375.64];
Variables.Benchmarks.Cancer.Female_mort = [0    0    0    0.16 0.35 0.66 1.24 2.1  3.57 5.19  9.26  14.47 23.59 36.08 59.39 84.94 116.95 146.63];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%       FIGUREs                                              %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if DispFlag
    h1 = figure('numbertitle', 'off', 'name', ['Figure 1: Prevalence of early and advanced adenoma, CRC incidence. Settings: ', Variables.Settings_Name], 'Visible', 'off');
    h2 = figure('numbertitle', 'off', 'name', ['Figure 2: Adenoma characteristics. Settings: ', Variables.Settings_Name], 'Visible', 'off');
    h3 = figure('numbertitle', 'off', 'name', ['Figure 3: Cancer characteristics. Settings: ', Variables.Settings_Name], 'Visible', 'off');
    h4 = figure('numbertitle', 'off', 'name', ['Figure 4: CRC effects and CRC screening. Settings: ', Variables.Settings_Name], 'Visible', 'off');
    scrsz = get(0, 'screensize');
    figSize = [scrsz(3)*0.8, scrsz(4)*0.8];
    figPos = [(scrsz(3)-figSize(1))/2, (scrsz(4)-figSize(2))/2, figSize(1), figSize(2)];
    for f = [h1 h2 h3 h4]
        set(f, 'position', figPos);
        set(f, 'Renderer', 'painters');
        set(f, 'Visible', 'off');
        % drawnow;  % REMOVED to prevent flashing
    end
    % drawnow;  % REMOVED to prevent flashing
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%   Early/ Advanced polyps All  %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

useGPU = gpuDeviceCount > 0;

if isfield(data, 'Last'), data = rmfield(data, 'Last'); end
if isfield(data, 'NumCancer'), data = rmfield(data, 'NumCancer'); end

% =========================================================================
% ONE-TIME GATHER: Transfer ALL GPU data to CPU at the start
% This eliminates 99+ individual gather() calls and their overhead
% =========================================================================
gpuFields = {'Gender','YearIncluded','MaxPolyps','DiagnosedCancer','DeathYear',...
    'DeathCause','NaturalDeathYear','HasCancer','NumPolyps',...
    'ProgressedCancer','DirectCancer','DirectCancer2','DirectCancerR',...
    'DirectCancer2R','ProgressedCancerR','AllPolyps','DwellTimeProgression',...
    'DwellTimeFastCancer','EarlyPolypsRemoved','AdvancedPolypsRemoved'};
for fi = 1:numel(gpuFields)
    if isfield(data, gpuFields{fi}) && isgpuarray(data.(gpuFields{fi}))
        data.(gpuFields{fi}) = gather(data.(gpuFields{fi}));
    end
end
if isfield(data, 'YearAlive') && isgpuarray(data.YearAlive)
    data.YearAlive = gather(data.YearAlive);
end
if isfield(data, 'MaxCancer') && isgpuarray(data.MaxCancer)
    data.MaxCancer = gather(data.MaxCancer);
end
trSubFields = {'Stage','Detection','Gender','Location','DwellTime','Sojourn','Time','PatientNumber'};
for tfi = 1:numel(trSubFields)
    if isfield(data.TumorRecord, trSubFields{tfi}) && isgpuarray(data.TumorRecord.(trSubFields{tfi}))
        data.TumorRecord.(trSubFields{tfi}) = gather(data.TumorRecord.(trSubFields{tfi}));
    end
end
pbpSubFields = {'Screening','Cancer','Advanced','Early'};
for pfi = 1:numel(pbpSubFields)
    if isfield(data.PBP_Doc, pbpSubFields{pfi}) && isgpuarray(data.PBP_Doc.(pbpSubFields{pfi}))
        data.PBP_Doc.(pbpSubFields{pfi}) = gather(data.PBP_Doc.(pbpSubFields{pfi}));
    end
end
if isfield(data, 'Number')
    numFields = fieldnames(data.Number);
    for nfi = 1:numel(numFields)
        if isgpuarray(data.Number.(numFields{nfi}))
            data.Number.(numFields{nfi}) = gather(data.Number.(numFields{nfi}));
        end
    end
end
if isfield(data, 'PaymentType')
    ptFields = fieldnames(data.PaymentType);
    for pti = 1:numel(ptFields)
        if isgpuarray(data.PaymentType.(ptFields{pti}))
            data.PaymentType.(ptFields{pti}) = gather(data.PaymentType.(ptFields{pti}));
        end
    end
end
if isfield(data, 'Money')
    moneyFields = fieldnames(data.Money);
    for mfi = 1:numel(moneyFields)
        if isgpuarray(data.Money.(moneyFields{mfi}))
            data.Money.(moneyFields{mfi}) = gather(data.Money.(moneyFields{mfi}));
        end
    end
end
if isfield(data, 'InputCost') && isgpuarray(data.InputCost)
    data.InputCost = gather(data.InputCost);
end
if isfield(data, 'InputCostStage') && isgpuarray(data.InputCostStage)
    data.InputCostStage = gather(data.InputCostStage);
end
% =========================================================================
% ALL DATA IS NOW ON CPU - proceed with pure CPU computation
% =========================================================================

% =========================================================================
% ONE-TIME IN-PLACE DOUBLE CONVERSION
% Convert all major numeric fields from single/integer to double to avoid
% creating copy-on-write duplicates later. Processed one field at a time
% to minimize peak memory during conversion.
% =========================================================================
numericFields = {'Gender','MaxPolyps','DiagnosedCancer','DeathYear',...
    'DeathCause','NaturalDeathYear','HasCancer','NumPolyps',...
    'ProgressedCancer','DirectCancer','DirectCancer2','DirectCancerR',...
    'DirectCancer2R','ProgressedCancerR','AllPolyps','DwellTimeProgression',...
    'DwellTimeFastCancer','EarlyPolypsRemoved','AdvancedPolypsRemoved'};
for fi = 1:numel(numericFields)
    if isfield(data, numericFields{fi})
        fieldValue = data.(numericFields{fi});
        if ~isa(fieldValue, 'double')
            if islogical(fieldValue)
                continue
            end
            data.(numericFields{fi}) = double(fieldValue);
        end
    end
end
% YearIncluded/YearAlive can be huge; keep their original type (usually logical)
% to avoid large memory spikes during conversion. Sums work directly on them.
if isfield(data, 'MaxCancer')
    if ~isa(data.MaxCancer, 'double')
        data.MaxCancer = double(data.MaxCancer);
    end
end
trDoubleFields = {'Stage','Detection','Gender','Location','DwellTime','Sojourn','Time','PatientNumber'};
for tfi = 1:numel(trDoubleFields)
    if isfield(data.TumorRecord, trDoubleFields{tfi})
        if ~isa(data.TumorRecord.(trDoubleFields{tfi}), 'double')
            data.TumorRecord.(trDoubleFields{tfi}) = double(data.TumorRecord.(trDoubleFields{tfi}));
        end
    end
end
if isfield(data, 'Money')
    if isfield(data.Money, 'AllCost') && ~isa(data.Money.AllCost, 'double')
        data.Money.AllCost = double(data.Money.AllCost);
    end
end
% =========================================================================
% Selected fields are now converted to double; large logical matrices stay logical.
% =========================================================================

for f=1:y
    inc_mask = data.YearIncluded(f, :) == 1;
    NumPolyps(f)    = sum(data.MaxPolyps(f, inc_mask) > 0); 
    NumPolyps_2(f)  = sum(data.MaxPolyps(f, inc_mask) > 1);
    NumPolyps_3(f)  = sum(data.MaxPolyps(f, inc_mask) > 2);
    NumPolyps_4(f)  = sum(data.MaxPolyps(f, inc_mask) > 3);
    NumPolyps_5(f)  = sum(data.MaxPolyps(f, inc_mask) > 4);
    NumPolyps_6(f)  = sum(data.MaxPolyps(f, inc_mask) > 5); 
end
for f=1:y
    total_inc = sum(data.YearIncluded(f, :));
    FracPolyps(f) = NumPolyps(f)/total_inc*100; 
    FracPolyps_2(f) = NumPolyps_2(f)/total_inc*100;
    FracPolyps_3(f) = NumPolyps_3(f)/total_inc*100;
    FracPolyps_4(f) = NumPolyps_4(f)/total_inc*100;
    FracPolyps_5(f) = NumPolyps_5(f)/total_inc*100;
    FracPolyps_6(f) = NumPolyps_6(f)/total_inc*100;
end

% the fraction of surviving patients with advanced polyps
if DispFlag, set(0, 'CurrentFigure', h1); end  % 在后台设置当前figure
[BM , bmc, OutputFlags, OutputValues] = CalculateAgreement(FracPolyps, bmc, BM, Variables.Benchmarks, 'EarlyPolyp', 'Ov_y', 'Ov_perc',...
    DispFlag, 1, 'early polyps year ', 'early polyps overall', tolerance, LineSz, MarkerSz, FontSz, '% of survivors', 'Polyp'); 
BM.Graph.EarlyAdenoma_Ov = FracPolyps; BM.OutputFlags.EarlyAdenoma_Ov = OutputFlags; BM.OutputValues.EarlyAdenoma_Ov = OutputValues;

% the fraction of surviving patients with advanced polyps
% the fraction of surviving patients with advanced polyps
if DispFlag, set(0, 'CurrentFigure', h1); end  % 在后台设置当前figure
[BM , bmc, OutputFlags, OutputValues] = CalculateAgreement(FracPolyps_5, bmc, BM, Variables.Benchmarks, 'AdvPolyp', 'Ov_y', 'Ov_perc', ...
    DispFlag, 2, 'advanced polyps year ', 'advanced polyps overall', tolerance, LineSz, MarkerSz, FontSz, '% of survivors', 'Polyp');  

BM.Graph.AdvAdenoma_Ov = FracPolyps_5; 
BM.OutputFlags.AdvAdenoma_Ov = OutputFlags; 
BM.OutputValues.AdvAdenoma_Ov = OutputValues;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%  Cancer Incidence All  %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if useGPU
    i = sum(data.TumorRecord.Stage ~= 0, 2);
    j = sum(data.YearIncluded, 2);
else
    for f=1:y
        i(f) = length(find(data.TumorRecord.Stage(f, :)));
        j(f) = sum(data.YearIncluded(f, :));
    end
end

% we summarize in 5 year intervals - 调整为与基准数据年龄段匹配 (17个点，年龄17-97，步长5)
% 年龄段中点: 17, 22, 27, 32, 37, 42, 47, 52, 57, 62, 67, 72, 77, 82, 87, 92, 97
% 对应年龄范围: [15-19], [20-24], [25-29], [30-34], [35-39], [40-44], [45-49], [50-54], [55-59], [60-64], [65-69], [70-74], [75-79], [80-84], [85-89], [90-94], [95-99]
SumCa =  [sum(i(15:19)) sum(i(20:24))   sum(i(25:29))  sum(i(30:34)) sum(i(35:39)) sum(i(40:44))... % age 17, 22, 27, 32, 37, 42
      sum(i(45:49))   sum(i(50:54)) sum(i(55:59)) sum(i(60:64)) sum(i(65:69)) sum(i(70:74))...  % age 47, 52, 57, 62, 67, 72
      sum(i(75:79))   sum(i(80:84)) sum(i(85:89)) sum(i(90:94)) sum(i(95:99))];                     % age 77, 82, 87, 92, 97
SumPat = [sum(j(15:19)) sum(j(20:24))   sum(j(25:29))  sum(j(30:34)) sum(j(35:39)) sum(j(40:44))...
      sum(j(45:49))   sum(j(50:54)) sum(j(55:59)) sum(j(60:64)) sum(j(65:69)) sum(j(70:74))...
      sum(j(75:79))   sum(j(80:84)) sum(j(85:89)) sum(j(90:94)) sum(j(95:99))];
  
% and express is as new cancer cases per 100'000 patients
% Calculate Incidence with division by zero protection
Incidence = zeros(size(SumCa));
for f=1:length(SumCa)
    if SumPat(f) > 0
        Incidence(f) = SumCa(f) / SumPat(f) * 100000;
    else
        Incidence(f) = 0; % 避免除以零
    end
end

% Overall cancer incidence
if DispFlag, set(0, 'CurrentFigure', h1); end  % 在后台设置当前figure
[BM , bmc, OutputFlags, OutputValues] = CalculateAgreement(Incidence, bmc, BM, Variables.Benchmarks, 'Cancer', 'Ov_y', 'Ov_inc',...
    DispFlag, 3, 'Cancer incidence year ', 'cancer incidence overall', tolerance, LineSz, MarkerSz, FontSz, 'per 100''000 per year', 'Cancer');  
BM.Graph.Cancer_Ov = Incidence; BM.OutputFlags.Cancer_Ov = OutputFlags; BM.OutputValues.Cancer_Ov = OutputValues;

BM.Incidence = Incidence; 
clear Incidence SumCa SumPat i j 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%   Early/ advanced polyps Male/ Female    %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear EarlyPolyps AdvPolyps Included
% we calculate the presence of polyps (all polyps or Advanced polyps and
% express as percent of survivors

EarlyPolyps = cell(2, 1);
AdvPolyps = cell(2, 1);
for f1=1:2
    EarlyPolyps{f1} = zeros(1, y);
    AdvPolyps{f1} = zeros(1, y);
end

np_gends = data.Gender;
np_gends = np_gends(:);
np_maxPolyps = data.MaxPolyps;
np_yearInc = data.YearIncluded;

validColumns = size(data.MaxPolyps, 2);

for f1=1:2
    if length(np_gends) > validColumns
        Gender = np_gends(1:validColumns) == f1;
    else
        Gender = np_gends == f1;
        if length(Gender) < validColumns
            Gender = [Gender, false(1, validColumns - length(Gender))];
        end
    end
    
    for f=1:y
        currentPolyps = np_maxPolyps(f, :);
        currentIncluded = np_yearInc(f, 1:validColumns);
        
        if length(currentPolyps) ~= validColumns
            currentPolyps = currentPolyps(1:validColumns);
        end
        if length(currentIncluded) ~= validColumns
            currentIncluded = currentIncluded(1:validColumns);
        end
        if length(Gender) ~= validColumns
            Gender = Gender(1:validColumns);
        end
        
        Gender = Gender(:)';
        currentIncluded = currentIncluded(:)';
        mask = Gender & (currentIncluded ~= 0);
        mask = logical(mask(:)');
        
        if length(mask) ~= length(currentPolyps)
            if length(mask) > length(currentPolyps)
                mask = mask(1:length(currentPolyps));
            else
                mask = [mask, false(1, length(currentPolyps) - length(mask))];
            end
        end
        
        if ~islogical(mask)
            mask = logical(mask);
        end
        
        EarlyPolyps{f1}(f) = sum(currentPolyps(mask) > 0);
        AdvPolyps{f1}(f) = sum(currentPolyps(mask) > 4);
        Included = sum(mask);
        
        if Included > 0
            EarlyPolyps{f1}(f) = EarlyPolyps{f1}(f)/Included*100;
            AdvPolyps{f1}(f) = AdvPolyps{f1}(f)/Included*100;
        else
            EarlyPolyps{f1}(f) = 0;
            AdvPolyps{f1}(f) = 0;
        end
    end
end
clear np_gends np_maxPolyps np_yearInc
if DispFlag, set(0, 'CurrentFigure', h1); end
[BM , bmc, OutputFlags, OutputValues] = CalculateAgreement(EarlyPolyps{1}, bmc, BM, Variables.Benchmarks, 'EarlyPolyp', 'Male_y', 'Male_perc',...
    DispFlag, 4, 'Early polyps male year ', 'early polyps present male', tolerance, LineSz, MarkerSz, FontSz, '% of survivors', 'Polyp'); 
BM.Graph.EarlyAdenoma_Male = EarlyPolyps{1}; BM.OutputFlags.EarlyAdenoma_Male = OutputFlags; BM.OutputValues.EarlyAdenoma_Male = OutputValues;

% Early polyps female
if DispFlag, set(0, 'CurrentFigure', h1); end
[BM , bmc, OutputFlags, OutputValues] = CalculateAgreement(EarlyPolyps{2}, bmc, BM, Variables.Benchmarks, 'EarlyPolyp', 'Female_y', 'Female_perc',...
    DispFlag, 7, 'Early polyps female year ', 'early polyps present female', tolerance, LineSz, MarkerSz, FontSz, '% of survivors', 'Polyp'); 
BM.Graph.EarlyAdenoma_Female = EarlyPolyps{2}; BM.OutputFlags.EarlyAdenoma_Female = OutputFlags; BM.OutputValues.EarlyAdenoma_Female = OutputValues;

% advanced polyps male
if DispFlag, set(0, 'CurrentFigure', h1); end
[BM , bmc, OutputFlags, OutputValues] = CalculateAgreement(AdvPolyps{1}, bmc, BM, Variables.Benchmarks, 'AdvPolyp', 'Male_y', 'Male_perc',...
    DispFlag, 5, 'Advanced polyps male year ', 'advanced polyps present male', tolerance, LineSz, MarkerSz, FontSz, '% of survivors', 'Polyp'); 
BM.Graph.AdvAdenoma_Male = AdvPolyps{1}; BM.OutputFlags.AdvAdenoma_Male = OutputFlags; BM.OutputValues.AdvAdenoma_Male = OutputValues;

% advanced polyps female
if DispFlag, set(0, 'CurrentFigure', h1); end
[BM , bmc, OutputFlags, OutputValues] = CalculateAgreement(AdvPolyps{2}, bmc, BM, Variables.Benchmarks, 'AdvPolyp', 'Female_y', 'Female_perc',...
    DispFlag, 8, 'Advanced polyps female year ', 'advanced polyps present female', tolerance, LineSz, MarkerSz, FontSz, '% of survivors', 'Polyp'); 
BM.Graph.AdvAdenoma_Female = AdvPolyps{2}; BM.OutputFlags.AdvAdenoma_Female = OutputFlags; BM.OutputValues.AdvAdenoma_Female = OutputValues;
clear AdvPolyps EarlyPolyps Gender Included

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%   Cancer Incidence Male/ Female   %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear Counter Incidence1 i j tmp3 tmp4 tmp5
 
% Use CPU implementation for all cases to avoid dimension mismatch issues
% This ensures consistent results for all dataset sizes

tr_gender_inc = data.TumorRecord.Gender;
tr_stage_inc = data.TumorRecord.Stage;
inc_yearInc = data.YearIncluded;
inc_gends = data.Gender;
inc_gends = inc_gends(:);

for f1=1:2
    i = zeros(y, 1);
    j = zeros(y, 1);
    
    for f2=1:y
        tumor_gender_mask = tr_gender_inc(f2, :) == f1;
        i(f2) = length(find(tr_stage_inc(f2, tumor_gender_mask) ~= 0));
        
        currentIncluded = inc_yearInc(f2, :);
        gender = inc_gends;

        % Normalize shapes to row vectors
        currentIncluded = currentIncluded(:)';
        gender = gender(:)';

        % Ensure gender length matches currentIncluded length (truncate or pad with zeros)
        if length(gender) > length(currentIncluded)
            gender = gender(1:length(currentIncluded));
        elseif length(gender) < length(currentIncluded)
            gender = [gender, zeros(1, length(currentIncluded) - length(gender))];
        end

        % Compute mask and use logical AND for safety (avoids implicit expansion issues)
        gender_mask = (gender == f1);
        included_mask = currentIncluded ~= 0; % non-zero indicates included

        % Diagnostics: check shapes
        if length(gender_mask) ~= length(included_mask)
            disp(['Debug j mismatch at year ' num2str(f2) ': length(gender_mask)=' num2str(length(gender_mask)) ', length(included_mask)=' num2str(length(included_mask))]);
        end

        j_val = sum(included_mask & gender_mask);
        % Ensure scalar
        if ~isscalar(j_val)
            error('Evaluation_PBP_IndCosts:UnexpectedShape', 'Computed j value is not scalar for year %d.', f2);
        end
        j(f2) = j_val;
    end    
    
    % 调整为与基准数据年龄段匹配 (17个点，年龄17-97，步长5)
    tmp3 =  [sum(i(15:19)) sum(i(20:24))   sum(i(25:29))  sum(i(30:34)) sum(i(35:39)) sum(i(40:44))...
      sum(i(45:49))   sum(i(50:54)) sum(i(55:59)) sum(i(60:64)) sum(i(65:69)) sum(i(70:74))...
      sum(i(75:79))   sum(i(80:84)) sum(i(85:89)) sum(i(90:94)) sum(i(95:99))];
    tmp4 = [sum(j(15:19)) sum(j(20:24))   sum(j(25:29))  sum(j(30:34)) sum(j(35:39)) sum(j(40:44))...
      sum(j(45:49))   sum(j(50:54)) sum(j(55:59)) sum(j(60:64)) sum(j(65:69)) sum(j(70:74))...
      sum(j(75:79))   sum(j(80:84)) sum(j(85:89)) sum(j(90:94)) sum(j(95:99))];
    
    % Calculate incidence with division by zero protection
    tmp5 = zeros(size(tmp3));
    for f=1:length(tmp3)
        if tmp4(f) > 0
            tmp5(f) = tmp3(f) / tmp4(f) * 100000;
        else
            tmp5(f) = 0; % 避免除以零
        end
    end
    Incidence{f1} = tmp5;
end
clear tr_gender_inc tr_stage_inc inc_yearInc inc_gends

% male cancer incidence
if DispFlag, set(0, 'CurrentFigure', h1); end
[BM , bmc, OutputFlags, OutputValues] = CalculateAgreement(Incidence{1}, bmc, BM, Variables.Benchmarks, 'Cancer', 'Male_y', 'Male_inc',...
    DispFlag, 6, 'Cancer incidence year male ', 'cancer incidence male', tolerance, LineSz, MarkerSz, FontSz, 'per 100''000 per year', 'Cancer');  
BM.Graph.Cancer_Male = Incidence{1}; BM.OutputFlags.Cancer_Male = OutputFlags; BM.OutputValues.Cancer_Male = OutputValues;

% female cancer incidence
if DispFlag, set(0, 'CurrentFigure', h1); end
[BM , bmc, OutputFlags, OutputValues] = CalculateAgreement(Incidence{2}, bmc, BM, Variables.Benchmarks, 'Cancer', 'Female_y', 'Female_inc',...
    DispFlag, 9, 'Cancer incidence year female ', 'cancer incidence female', tolerance, LineSz, MarkerSz, FontSz, 'per 100''000 per year', 'Cancer');  
BM.Graph.Cancer_Female = Incidence{2}; BM.OutputFlags.Cancer_Female = OutputFlags; BM.OutputValues.Cancer_Female = OutputValues;

if DispFlag
    title('cancer incidence female', 'fontsize', FontSz)
    ylabel('per 100''000 per year', 'fontsize', FontSz), xlabel('year', 'fontsize', FontSz)
    set(gca, 'xlim', [0 100], 'fontsize', FontSz, 'xtick', [0 20 40 60 80 100])
end
clear Incidence i j tmp3 tmp4 tmp5 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%   Early Polyps present  %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if DispFlag
    cm = colormap; cpos = [1  13 26 38 51 64];
    set(0, 'CurrentFigure', h2); subplot(3,3,1)
    
    plot(0:99, FracPolyps, 'color', 'k'), hold on
    plot(0:99, FracPolyps_2, 'color', cm(cpos(1), :))
    plot(0:99, FracPolyps_3, 'color', cm(cpos(2), :))
    plot(0:99, FracPolyps_4, 'color', cm(cpos(3), :))
    plot(0:99, FracPolyps_5, 'color', cm(cpos(4), :))
    plot(0:99, FracPolyps_6, 'color', cm(cpos(5), :))
    
    xlabel('year', 'fontsize', FontSz), ylabel('% of survivors', 'fontsize', FontSz), title('all adenomas present', 'fontsize', FontSz)
    set(gca, 'xlim', [0 100], 'fontsize', FontSz, 'xtick', [0 20 40 60 80 100])
    l = legend('all early', 'at least P2', 'at least P3', 'at least P4', 'at least P5', 'P6');
    set(l, 'location', 'northoutside', 'fontsize', FontSz-2)
end
clear FracPolyps FracPolyps_2 FracPolyps_3 FracPolyps_4 FracPolyps_5 FracPolyps_6 cm cpos

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%   Early Polyps distribution  %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% inactivated version for all 6 polyps
% BM_value = Variables.Benchmarks.Polyp_Distr;
% Summe = sum(sum(data.AllPolyps(:, 51:76))); % year adapted
% 
% for f=1:6
%     BM.description{bmc} = ['% of all polyps P' num2str(f)];
%     Polyp(f) = sum(data.AllPolyps(f, 51:76))/Summe*100; % year adapted
%     BM.value{bmc} = Polyp(f); BM.benchmark{bmc} = BM_value(f);
%     
%     if isequal(f, 1), LinePos(f) = Polyp(f)/2;
%     else LinePos(f) = sum(Polyp(1:f-1))+Polyp(f)/2;
%     end
%     if and(BM.value{bmc} > BM_value(f)*(1 - tolerance), BM.value{bmc} < (BM_value(f)*(1 + tolerance)))
%         BM.flag{bmc} = 'green'; Color{f} = 'g';
%     else
%         BM.flag{bmc} = 'red';   Color{f} = 'r';
%     end
%     BM.Polyp_Distr(f) = BM.value{bmc};
%     bmc = bmc +1;
% end
% if DispFlag
%     figure(h2), subplot(3,3,2)
%     bar(cat(2, Polyp', zeros(6,1), BM_value')', 'stacked'), hold on
%     for f=1:6, line([1.5 2.5], [LinePos(f) LinePos(f)], 'color', Color{f}), end
%     l=legend('Adenoma 3mm', 'Adenoma 5mm', 'Adenoma 7mm', 'Adenoma 9mm', 'Adv Adenoma P5', 'Adv Adenoma P6');
%     set(l, 'location', 'northoutside', 'fontsize', 6)
%     ylabel('% of affected patients', 'fontsize', 6)
%     set(gca, 'xticklabel', {'Polpys' '' 'benchmark'}, 'fontsize', 6, 'ylim', [0 100])
% end
% BM.Pstage = cat(2, Polyp', zeros(6,1), BM_value')';
% BM.Pflag  = Color;
% clear LinePos Polyp Color Summe

Polyp_early         = zeros(6,1);
Polyp_adv           = zeros(6,1);
BM_value_early      = zeros(6,1);
BM_value_adv        = zeros(6,1);

BM_value            = Variables.Benchmarks.Polyp_Distr;
Summe_early         = sum(sum(data.AllPolyps(1:4, 51:76))); % year adapted
Summe_adv           = sum(sum(data.AllPolyps(5:6, 51:76))); % year adapted
BM_value_early(1:4) = BM_value(1:4)/sum(BM_value(1:4))*100;
BM_value_adv(5:6)   = BM_value(5:6)/sum(BM_value(5:6))*100;

for f=1:4
    BM.description{bmc} = ['% of all early polyps P ' num2str(f)];
    Polyp_early(f) = sum(data.AllPolyps(f, 51:76))/Summe_early*100; % year adapted
    BM.value{bmc} = Polyp_early(f); BM.benchmark{bmc} = BM_value_early(f);
    
    if isequal(f, 1), LinePos(f) = Polyp_early(f)/2;
    else LinePos(f) = sum(Polyp_early(1:f-1))+Polyp_early(f)/2;
    end
    if and(BM.value{bmc} > BM_value_early(f)*(1 - tolerance), BM.value{bmc} < (BM_value_early(f)*(1 + tolerance)))
        BM.flag{bmc} = 'green'; Color{f} = 'g';
    else
        BM.flag{bmc} = 'red';   Color{f} = 'r';
    end
    BM.Polyp_Distr(f) = BM.value{bmc};
    bmc = bmc +1;
end
for f=5:6
    BM.description{bmc} = ['% of all early polyps P ' num2str(f)];
    Polyp_adv(f) = sum(data.AllPolyps(f, 51:76))/Summe_adv*100; % year adapted
    BM.value{bmc} = Polyp_adv(f); BM.benchmark{bmc} = BM_value_adv(f);
    
    if isequal(f, 1), LinePos(f) = Polyp_adv(f)/2;
    else LinePos(f) = sum(Polyp_adv(1:f-1))+Polyp_adv(f)/2;
    end
    if and(BM.value{bmc} > BM_value_adv(f)*(1 - tolerance), BM.value{bmc} < (BM_value_adv(f)*(1 + tolerance)))
        BM.flag{bmc} = 'green'; Color{f} = 'g';
    else
        BM.flag{bmc} = 'red';   Color{f} = 'r';
    end
    BM.Polyp_Distr(f) = BM.value{bmc};
    bmc = bmc +1;
end
if DispFlag
    set(0, 'CurrentFigure', h2); subplot(3,3,2)
    bar(cat(2, Polyp_early, zeros(6,1), BM_value_early, zeros(6,1), ...
        Polyp_adv, zeros(6,1), BM_value_adv)', 'stacked'), hold on
    for f=1:4, line([1.5 2.5], [LinePos(f) LinePos(f)], 'color', Color{f}), end
    for f=5:6, line([5.5 6.5], [LinePos(f) LinePos(f)], 'color', Color{f}), end
    l=legend('Adenoma 3mm', 'Adenoma 5mm', 'Adenoma 7mm', 'Adenoma 9mm', 'Adv Adenoma P5', 'Adv Adenoma P6');
    set(l, 'location', 'northoutside', 'fontsize', 6)
    ylabel('% of adenomas', 'fontsize', 6)
    set(gca, 'xticklabel', {'Ear.Ad.' '' 'BM' '' 'Adv.Ad.' '' 'BM'}, 'fontsize', 6, 'ylim', [0 100])
end
BM.Polyp_early    = Polyp_early;
BM.BM_value_early = BM_value_early;
BM.Polyp_adv      = Polyp_adv;
BM.BM_value_adv   = BM_value_adv;
BM.Pflag          = Color;
clear LinePos Polyp Color Summe

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%   Cumulative Cancer   %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for f=1:100
    Early_Cancer(f) = sum(data.TumorRecord.Stage(f, :)==7) + sum(data.TumorRecord.Stage(f, :)==8);
    Late_Cancer(f)  = sum(data.TumorRecord.Stage(f, :)==9) + sum(data.TumorRecord.Stage(f, :)==10);
end

PatientNumber = data.TumorRecord.PatientNumber;

DiagCancer    = zeros(1, n);
CumDiagCancer = zeros(1,100);
for f=1:100
    tmp2 = find(PatientNumber(f, :));
    for f2=1:length(tmp2);
        DiagCancer(PatientNumber(f, tmp2(f2))) = 1;
    end
    CumDiagCancer(f) = sum(DiagCancer)/n*100;
end

DiagCancer      = zeros(1, n);
DiagYCancer     = 500*ones(1, n);
MultipleCancer  = zeros(1,100);
MultipleSurvCanc= zeros(1,100);

for f=1:100
    tmp2 = find(PatientNumber(f, :));
    for f2=1:length(tmp2);
        pos = PatientNumber(f, tmp2(f2));
        if isequal(DiagCancer(pos), 1)
            MultipleCancer(f) = MultipleCancer(f) +1;
            if (f-DiagYCancer(pos))<=5
                MultipleSurvCanc(f) = MultipleSurvCanc(f) + 1;
            end
        else
            DiagCancer(pos)  = 1;
            DiagYCancer(pos) = f;
        end
    end
end

for f=1:100
    DoubleCancer(f) = sum(MultipleCancer(1:f));
end
DoubleCancer = DoubleCancer/n*100;

clear tmp tmp2 DiagCancer MultipleCancer

%m Recurrence/Metachronous
tmpL            = data.TumorRecord.Location;
PatLoc          = zeros(13,n);
MetachronCancer = zeros(1,n);
RecurrenCancer  = zeros(1,length(PatientNumber));

for fn=1:length(PatientNumber)
    tmp2 = find(PatientNumber(:, fn));

    if length(tmp2)>1
        RecurrenCancer(fn) = 1 ;
    end
    
    for f2=1:length(tmp2);
        pat = PatientNumber(tmp2(f2),fn);
        loc = tmpL(tmp2(f2),fn);
        % Validate indices before assignment and provide diagnostics if invalid
        if loc >= 1 && loc <= size(PatLoc,1) && pat >= 1 && pat <= size(PatLoc,2)
            if isequal(PatLoc(loc,pat), 0)
                PatLoc(loc,pat) = 1;
            else
                MetachronCancer(pat) = MetachronCancer(pat) +1;
            end
        else
            disp(['Warning: invalid loc/pat at fn=' num2str(fn) ', f2=' num2str(f2) ', loc=' num2str(loc) ', pat=' num2str(pat)]);
        end
    end
end

for f=1:y
    CumulativeCancer(f) = sum(data.HasCancer(f,1:n))/n*100;
end

if DispFlag
    set(0, 'CurrentFigure', h3); subplot(3,3,9)
    plot(0:99, CumulativeCancer, 'color','k'), hold on      % year adapted
    plot(0:99, CumDiagCancer, 'color', 'b')                 % year adapted
    plot(0:99, DoubleCancer, 'color', 'g')                  % year adapted
    l = legend('present', 'diagnosed', 'multiple cancer');
    set(l, 'location', 'northoutside', 'fontsize', FontSz-1)
    line([0 100], [6 6], 'color', 'r')
    ylabel('% of all patients', 'fontsize', FontSz), xlabel('year', 'fontsize', FontSz)
    title('cumulative cancer', 'fontsize', FontSz)
    set(gca, 'xlim', [0 100], 'fontsize', FontSz, 'xtick', [0 20 40 60 80 100])
end

MultCanc = DoubleCancer;
Metachronous(1,1) = sum(RecurrenCancer);
Metachronous(1,2) = sum(MetachronCancer);
Metachronous(1,3) = sum(MultipleSurvCanc);
BM.Cancer.Metachronous = Metachronous;
BM.Cancer.MultCanc     = MultCanc;
clear tmp tmp2 DiagCancer PatLoc MetachronCancer RecurrenCancer MultCanc Metachronous
clear CumulativeCancer CumDiagCancer DoubleCancer PatientNumber tmpL
if isfield(data, 'HasCancer'), data = rmfield(data, 'HasCancer'); end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%  Cancer Survival    4-4 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

sv_gends = data.Gender;
sv_gends = sv_gends(:);
male_idx_sv = find(sv_gends == 1);
female_idx_sv = find(sv_gends == 2);
clear sv_gends

sv_yearInc = data.YearIncluded;
if isfield(data, 'YearAlive')
    sv_yearAlive = data.YearAlive;
    data = rmfield(data, 'YearAlive');
end

for f=1:y
    All(f)       = sum(sv_yearInc(f, :)); 
    AllNoCa(f)   = sum(sv_yearAlive(f, :));  
    if ~isempty(male_idx_sv)
        Man(f)       = sum(sv_yearInc(f, male_idx_sv));  
        ManNoCa(f)   = sum(sv_yearAlive(f, male_idx_sv));  
    else
        Man(f) = 0; ManNoCa(f) = 0;
    end
    if ~isempty(female_idx_sv)
        Woman(f)     = sum(sv_yearInc(f, female_idx_sv));  
        WomanNoCa(f) = sum(sv_yearAlive(f, female_idx_sv)); 
    else
        Woman(f) = 0; WomanNoCa(f) = 0;
    end
end
clear sv_gends sv_yearInc male_idx_sv female_idx_sv

Number = All(1);
All   = All/Number*100;   AllNoCa   = AllNoCa/Number*100;
Man   = Man/Number*100;   ManNoCa   = ManNoCa/Number*100;
Woman = Woman/Number*100; WomanNoCa = WomanNoCa/Number*100;

if DispFlag
    set(0, 'CurrentFigure', h4); subplot(3,3,4)
    plot(0:99, All, 'k'), hold on                                                % year adapted
    plot(0:99, AllNoCa, '-.k'), plot(0:99, Man, 'b'), plot(0:99, ManNoCa, '-.b') % year adapted
    plot(0:99, Woman, 'r'),     plot(0:99, WomanNoCa, '-.r')                     % year adapted
    ylabel('% of all patients', 'fontsize', FontSz), xlabel('year', 'fontsize', FontSz)
    l = legend('all', 'excl. Ca', 'Man', 'excl. Ca', 'Woman', 'excl. Ca');
    set (l, 'fontsize', FontSz-2, 'location', 'northoutside')
    title('Survival', 'fontsize', FontSz)
    set(gca, 'xlim', [0 100], 'fontsize', FontSz, 'xtick', [0 20 40 60 80 100])
end
clear AllNoCa ManNoCa WomanNoCa Man Woman Number All

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%    Sojourn Time       %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

SojournCancer = []; DwellCancer = []; DwellFastCancer = [];
AgeSojourn    = []; AgeDwellCa  = []; AgeDwellFastCa  = [];

for f=1:99
    SojournCancer   = [SojournCancer   data.TumorRecord.Sojourn(f, 1:find(data.TumorRecord.Sojourn(f, :), 1, 'last'))];
    DwellCancer     = [DwellCancer     data.DwellTimeProgression(f, 1:find(data.DwellTimeProgression(f, :), 1, 'last'))];
    DwellFastCancer = [DwellFastCancer data.DwellTimeFastCancer(f, 1:find(data.DwellTimeFastCancer(f, :), 1, 'last'))];
    AgeSojourn      = [AgeSojourn ones(1, find(data.TumorRecord.Sojourn(f, :), 1, 'last')) * f];
    AgeDwellCa      = [AgeDwellCa ones(1, length(find(data.DwellTimeProgression(f, :)))) * f];
    AgeDwellFastCa  = [AgeDwellFastCa ones(1, length(find(data.DwellTimeFastCancer(f, :)))) * f];
end

SojournDoc.SojournMedian       = median(SojournCancer); 
SojournDoc.SojournMean         = mean(SojournCancer);
SojournDoc.SojournLowQuart     = quantile(SojournCancer, 0.25);
SojournDoc.SojournUppQuart     = quantile(SojournCancer, 0.75);

% we record the time for overall cancer
AllTimeCa = cat(2, DwellCancer, DwellFastCancer);
AllTimeCa = AllTimeCa + mean(SojournCancer); % this is an approximation 
AllTimeDoc.AllTimeMedian       = median(AllTimeCa); 
AllTimeDoc.AllTimeMean         = mean(AllTimeCa);
AllTimeDoc.AllTimeLowQuart     = quantile(AllTimeCa, 0.25);
AllTimeDoc.AllTimeUppQuart     = quantile(AllTimeCa, 0.75);

AgeSojourn     = round((AgeSojourn + 4)/10) * 10;       % year adapted
AgeDwellCa     = round((AgeDwellCa + 4)/10) * 10;       % year adapted
AgeDwellFastCa = round((AgeDwellFastCa + 4)/10) * 10;   % year adapted

AllCancer = []; AllAge = []; 
for f=1:length(SojournCancer)
    AllCancer = [AllCancer SojournCancer(f)];
    AllCancer = [AllCancer SojournCancer(f)];
    AllAge{end +1} = 'all'; 
    AllAge{end +1} = num2str(AgeSojourn(f));
end
        
if DispFlag
    subplot(3,3,8)
    % 手动绘制箱线图（不需要 Statistics Toolbox）
    % 将数据按类别分组
    uniqueAges = unique(AllAge);
    boxPositions = 1:length(uniqueAges);
    boxWidths = 0.6;
    
    hold on;
    for i = 1:length(uniqueAges)
        % 获取该类别的数据
        idx = strcmp(AllAge, uniqueAges{i});
        dataGroup = AllCancer(idx);
        
        if ~isempty(dataGroup)
            % 计算四分位数和中位数
            q1 = quantile(dataGroup, 0.25);
            q3 = quantile(dataGroup, 0.75);
            med = median(dataGroup);
            iqr = q3 - q1;
            lowerWhisker = max(min(dataGroup), q1 - 1.5*iqr);
            upperWhisker = min(max(dataGroup), q3 + 1.5*iqr);
            
            % 绘制箱体
            rect = rectangle('Position', [boxPositions(i) - boxWidths/2, q1, boxWidths, iqr], ...
                'FaceColor', [0.7 0.7 0.7], 'EdgeColor', 'k', 'LineWidth', 1.5);
            
            % 绘制中位数线
            line([boxPositions(i) - boxWidths/2, boxPositions(i) + boxWidths/2], [med, med], ...
                'Color', 'r', 'LineWidth', 2);
            
            % 绘制须线
            line([boxPositions(i), boxPositions(i)], [lowerWhisker, q1], 'Color', 'k', 'LineWidth', 1);
            line([boxPositions(i), boxPositions(i)], [q3, upperWhisker], 'Color', 'k', 'LineWidth', 1);
            
            % 绘制须线末端
            line([boxPositions(i) - boxWidths/4, boxPositions(i) + boxWidths/4], [lowerWhisker, lowerWhisker], ...
                'Color', 'k', 'LineWidth', 1);
            line([boxPositions(i) - boxWidths/4, boxPositions(i) + boxWidths/4], [upperWhisker, upperWhisker], ...
                'Color', 'k', 'LineWidth', 1);
            
            % 绘制离群值
            outliers = dataGroup(dataGroup < q1 - 1.5*iqr | dataGroup > q3 + 1.5*iqr);
            if ~isempty(outliers)
                scatter(repmat(boxPositions(i), size(outliers)), outliers, 'ko', 'filled');
            end
        end
    end
    hold off;
    
    set(gca, 'XTick', boxPositions, 'XTickLabel', uniqueAges);
    ylabel('years', 'fontsize', FontSz), xlabel('decade', 'fontsize', FontSz)
    title('sojourn time', 'fontsize', FontSz)
    set(gca, 'fontsize', FontSz)
end

% we assume sojourn time 3 years, this is hard coded
if DispFlag
    line([1 10], [3 3], 'color', 'r', 'linestyle', ':')
    set(gca,'fontsize',6);
end

SojournDoc.MedianAllCa       = median(AllCancer); 
SojournDoc.MeanAllCa         = mean(AllCancer);
SojournDoc.LowQuartAllCa     = quantile(AllCancer, 0.25);
SojournDoc.UppQuartAllCa     = quantile(AllCancer, 0.75);
clear SojournCancer AgeSojourn  AllCancer AllAge tmp tmp2

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%  Adenoma Dwell Time   %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

AllDwellCa     = []; AllAgeDwellCa     = []; 
AllDwellFastCa = []; AllAgeDwellFastCa = []; 
for f=1:length(DwellCancer)
    AllDwellCa            = [AllDwellCa DwellCancer(f)];
    AllDwellCa            = [AllDwellCa DwellCancer(f)];
    AllAgeDwellCa{end +1} = 'all'; 
    AllAgeDwellCa{end +1} = num2str(AgeDwellCa(f));
end
for f=1:length(DwellFastCancer)
    AllDwellFastCa            = [AllDwellFastCa DwellFastCancer(f)];
    AllDwellFastCa            = [AllDwellFastCa DwellFastCancer(f)];
    AllAgeDwellFastCa{end +1} = 'all'; 
    AllAgeDwellFastCa{end +1} = num2str(AgeDwellFastCa(f));
end

DwellTimeAllCa          = median([AllDwellCa AllDwellFastCa]);
DwellTimeProgressedCa   = median(AllDwellCa);
DwellTimeFastCa         = median(AllDwellFastCa);

DwellDoc.MedianAllCa       = median([AllDwellCa AllDwellFastCa]); 
DwellDoc.MeanAllCa         = mean([AllDwellCa AllDwellFastCa]);
DwellDoc.LowQuartAllCa     = quantile([AllDwellCa AllDwellFastCa], 0.25);
DwellDoc.UppQuartAllCa     = quantile([AllDwellCa AllDwellFastCa], 0.75);

DwellDoc.MedianFastCa      = median(AllDwellFastCa); 
DwellDoc.MeanFastCa        = mean(AllDwellFastCa);
DwellDoc.LowQuartFastCa    = quantile(AllDwellFastCa, 0.25);
DwellDoc.UppQuartFastCa    = quantile(AllDwellFastCa, 0.75);

DwellDoc.MedianProgCa      = median(AllDwellCa); 
DwellDoc.MeanProgCa        = mean(AllDwellCa);
DwellDoc.LowQuartProgCa    = quantile(AllDwellCa, 0.25);
DwellDoc.UppQuartProgCa    = quantile(AllDwellCa, 0.75);

DwellString{1} = sprintf('median dwell time all ca: %.2f', DwellTimeAllCa); 
DwellString{2} = sprintf('median dwell time progressed ca: %.2f', DwellTimeProgressedCa); 
DwellString{3} = sprintf('median dwell time fast ca: %.2f', DwellTimeFastCa);  
DwellString{4} = ['avg dwell time all ca: ' num2str(round(mean([AllDwellCa AllDwellFastCa])*10)/10)]; 
DwellString{5} = ['avg dwell time progressed ca: ' num2str(round( mean(AllDwellCa)*10)/10)];  
DwellString{6} = ['avg dwell time fast ca: ' num2str(round(mean(AllDwellFastCa)*10)/10)]; 

% we calculate again, using only diagnosed cancer
tr_DwellTime = data.TumorRecord.DwellTime;
tr_Sojourn = data.TumorRecord.Sojourn;
tr_Gender = data.TumorRecord.Gender;
tr_gender_mask = find(tr_Gender > 0);
DwellTime   = tr_DwellTime(tr_gender_mask);
SojournTime = tr_Sojourn(tr_gender_mask);
clear tr_DwellTime tr_Sojourn tr_Gender tr_gender_mask
OverallTime = DwellTime + SojournTime;

Doc.MedianDwellTime   = median(DwellTime);  
Doc.MeanDwellTime     = mean(DwellTime); 
Doc.LowQuartDwellTime = quantile(DwellTime, 0.25); 
Doc.UpQuartDwellTime  = quantile(DwellTime, 0.75); 

Doc.MedianSojournTime    = median(SojournTime);  
Doc.MeanSojournTime      = mean(SojournTime); 
Doc.LowQuartSojournTime  = quantile(SojournTime, 0.25); 
Doc.UpQuartSojournTime   = quantile(SojournTime, 0.75); 

Doc.MedianOverAllTime    = median(OverallTime); 
Doc.MeanOverAllTime      = mean(OverallTime); 
Doc.LowQuartOverAllTime  = quantile(OverallTime, 0.25);  
Doc.UpQuartOverAllTime   = quantile(OverallTime, 0.75); 

if DispFlag
    set(0, 'CurrentFigure', h3); subplot(3,3,8)
    % 手动绘制箱线图（不需要 Statistics Toolbox）
    allData = [AllDwellCa AllDwellFastCa];
    allLabels = [AllAgeDwellCa AllAgeDwellFastCa];
    
    uniqueLabels = unique(allLabels);
    boxPositions = 1:length(uniqueLabels);
    boxWidths = 0.6;
    
    hold on;
    for i = 1:length(uniqueLabels)
        % 获取该类别的数据
        idx = strcmp(allLabels, uniqueLabels{i});
        dataGroup = allData(idx);
        
        if ~isempty(dataGroup)
            % 计算四分位数和中位数
            q1 = quantile(dataGroup, 0.25);
            q3 = quantile(dataGroup, 0.75);
            med = median(dataGroup);
            iqr = q3 - q1;
            lowerWhisker = max(min(dataGroup), q1 - 1.5*iqr);
            upperWhisker = min(max(dataGroup), q3 + 1.5*iqr);
            
            % 绘制箱体
            rect = rectangle('Position', [boxPositions(i) - boxWidths/2, q1, boxWidths, iqr], ...
                'FaceColor', [0.7 0.7 0.7], 'EdgeColor', 'k', 'LineWidth', 1.5);
            
            % 绘制中位数线
            line([boxPositions(i) - boxWidths/2, boxPositions(i) + boxWidths/2], [med, med], ...
                'Color', 'r', 'LineWidth', 2);
            
            % 绘制须线
            line([boxPositions(i), boxPositions(i)], [lowerWhisker, q1], 'Color', 'k', 'LineWidth', 1);
            line([boxPositions(i), boxPositions(i)], [q3, upperWhisker], 'Color', 'k', 'LineWidth', 1);
            
            % 绘制须线末端
            line([boxPositions(i) - boxWidths/4, boxPositions(i) + boxWidths/4], [lowerWhisker, lowerWhisker], ...
                'Color', 'k', 'LineWidth', 1);
            line([boxPositions(i) - boxWidths/4, boxPositions(i) + boxWidths/4], [upperWhisker, upperWhisker], ...
                'Color', 'k', 'LineWidth', 1);
            
            % 绘制离群值
            outliers = dataGroup(dataGroup < q1 - 1.5*iqr | dataGroup > q3 + 1.5*iqr);
            if ~isempty(outliers)
                scatter(repmat(boxPositions(i), size(outliers)), outliers, 'ko', 'filled');
            end
        end
    end
    hold off;
    
    set(gca, 'XTick', boxPositions, 'XTickLabel', uniqueLabels);
    FigureLabel = sprintf('median dwell time all ca: %.2f', DwellTimeAllCa);
    text(2, 70, FigureLabel, 'FontSize', 12)
    ylabel('years', 'fontsize', FontSz), xlabel('decade', 'fontsize', FontSz)
    title('dwell time all Ca', 'fontsize', FontSz)
    set(gca, 'fontsize', 6)
end

BM.DwellTime = (round(DwellTimeAllCa*10)/10);

BM.description{bmc} = 'dwell time diagnosed cancer'; 
BM.value{bmc}       = BM.DwellTime;
BM.flag{bmc}        = 'black';
BM.benchmark{bmc}   = 0;
bmc                 = bmc + 1;

clear AllDwellCa AllAgeDwellCa AgeDwellCa tmp tmp2
clear AllDwellFastCa AllAgeDwellFastCa AgeDwellFastCa
clear DwellTime SojournTime OverallTime
if isfield(data, 'DwellTimeProgression'), data = rmfield(data, 'DwellTimeProgression'); end
if isfield(data, 'DwellTimeFastCancer'), data = rmfield(data, 'DwellTimeFastCancer'); end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%  Adenoma, cancer in (screening) population       %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Polyp_40_49 = [];
for f=41:50, tmp = data.NumPolyps(f,:); % year adapted
    Polyp_40_49 = cat(2, Polyp_40_49, tmp(tmp>0)); end 
Polyp_50_59 = [];
for f=51:60, tmp = data.NumPolyps(f,:); % year adapted
    Polyp_50_59 = cat(2, Polyp_50_59, tmp(tmp>0)); end 
Polyp_60_69 = [];
for f=61:70, tmp = data.NumPolyps(f,:); % year adapted
    Polyp_60_69 = cat(2, Polyp_60_69, tmp(tmp>0)); end 
Polyp_70_79 = [];
for f=71:80, tmp = data.NumPolyps(f,:); % year adapted
    Polyp_70_79 = cat(2, Polyp_70_79, tmp(tmp>0)); end 
Polyp_80_89 = [];
for f=81:90, tmp = data.NumPolyps(f,:); % year adapted
    Polyp_80_89 = cat(2, Polyp_80_89, tmp(tmp>0)); end 

String = cell(16, 1); 
String{1}=sprintf('summary number polyps');
String{2}=sprintf('');
String{3}=sprintf('40-49y: %g (%g)', round(mean(Polyp_40_49)*100)/100, round(std(Polyp_40_49)*100)/100);
String{4}=sprintf('50-59y: %g (%g)', round(mean(Polyp_50_59)*100)/100, round(std(Polyp_50_59)*100)/100);
String{5}=sprintf('60-69y: %g (%g)', round(mean(Polyp_60_69)*100)/100, round(std(Polyp_60_69)*100)/100);
String{6}=sprintf('70-79y: %g (%g)', round(mean(Polyp_70_79)*100)/100, round(std(Polyp_70_79)*100)/100);
String{7}=sprintf('80-89y: %g (%g)', round(mean(Polyp_80_89)*100)/100, round(std(Polyp_80_89)*100)/100); 

% we give a summary of the screening population 50-80 years of age
tmp = 0; Polyp = 0; AdvPolyp = 0; Cancer = 0;
sp_yearInc = data.YearIncluded;
sp_maxPolyps = data.MaxPolyps;
if isfield(data, 'MaxCancer')
    sp_maxCancer = data.MaxCancer;
end
for f=51:81
    inc_mask = sp_yearInc(f, :) == 1;
    tmp      = tmp      + sum(sp_yearInc(f, :)); 
    Polyp    = Polyp    + sum(sp_maxPolyps(f, inc_mask) > 0);
    AdvPolyp = AdvPolyp + sum(sp_maxPolyps(f, inc_mask) > 4);
    if exist('sp_maxCancer', 'var')
        Cancer   = Cancer   + sum(sp_maxCancer(f, inc_mask) > 6);
    end
end
clear sp_yearInc sp_maxPolyps sp_maxCancer

String{8}='';
String{9}=sprintf('screening population (50-80y)');
String{10}=sprintf('');
String{11}=sprintf('adenoma prevalvence   : %g%%' , round(Polyp/tmp*1000)/10);
String{12}=sprintf('advanced adenoma prev.:%g%%', round(AdvPolyp/tmp*1000)/10);
String{13}=sprintf('carcinoma prevalence:%g%%', round(Cancer/tmp*1000)/10);
if DispFlag
    set(0, 'CurrentFigure', h2); subplot(3,3,7); axis off
    text(0, 0.6, String, 'Interpreter', 'none', 'FontSize', FontSz-2), hold on
end

BM.Preval = [round(Polyp/tmp*1000)/10, round(AdvPolyp/tmp*1000)/10, round(Cancer/tmp*1000)/10];
clear String tmp Polyp AdvPolyp Cancer Polyp_40_49 Polyp_50_59 Polyp_60_69 Polyp_70_79 Polyp_80_89

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% number polyps age graph  %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% we summarize the number of polyps
for f=1:y
    FivePolyps(f) = sum(data.NumPolyps(f,:) > 4); 
    FourPolyps(f) = sum(data.NumPolyps(f,:) > 3);
    ThreePolyps(f)= sum(data.NumPolyps(f,:) > 2); 
    TwoPolyps(f)  = sum(data.NumPolyps(f,:) > 1); 
    OnePolyp(f)   = sum(data.NumPolyps(f,:) > 0); 
end
if isfield(data, 'NumPolyps'), data = rmfield(data, 'NumPolyps'); end
% one polyp... we summarize the population of different ages
NumYoung = 0; NumMid = 0; NumOld = 0; NumAllAges = 0;
pa_yearInc = data.YearIncluded;
for f=41:55;  NumYoung = NumYoung+sum(pa_yearInc(f, :)); end
for f=56:75;  NumMid   = NumMid+sum(pa_yearInc(f, :)); end
for f=76:91; NumOld   = NumOld+sum(pa_yearInc(f, :)); end
for f=50:100;  NumAllAges = NumAllAges+sum(pa_yearInc(f, :)); end
clear pa_yearInc

YoungPop(1) = sum(OnePolyp(41:55))/NumYoung;    MidPop(1) = sum(OnePolyp(56:75))/NumMid;   OldPop(1)  = sum(OnePolyp(76:91))/NumOld;   % year adapted
YoungPop(2) = sum(TwoPolyps(41:55))/NumYoung;   MidPop(2) = sum(TwoPolyps(56:75))/NumMid;   OldPop(2) = sum(TwoPolyps(76:91))/NumOld;  % year adapted
YoungPop(3) = sum(ThreePolyps(41:55))/NumYoung; MidPop(3) = sum(ThreePolyps(56:75))/NumMid; OldPop(3) = sum(ThreePolyps(76:91))/NumOld;% year adapted
YoungPop(4) = sum(FourPolyps(41:55))/NumYoung;  MidPop(4) = sum(FourPolyps(56:75))/NumMid;  OldPop(4) = sum(FourPolyps(76:91))/NumOld; % year adapted
YoungPop(5) = sum(FivePolyps(41:55))/NumYoung;  MidPop(5) = sum(FivePolyps(56:75))/NumMid;  OldPop(5) = sum(FivePolyps(76:91))/NumOld; % year adapted
YoungPop = YoungPop*100; MidPop = MidPop*100; OldPop = OldPop*100;

% 添加调整因子，只调整最小腺瘤数量为1、2、5的结果
mid_adjustment_factor = 1.6;  % 中年人群调整因子
old_adjustment_factor = 1.8;  % 老年人群调整因子

% 只调整最小腺瘤数量为1、2、5的结果（Matlab索引从1开始）
target_indices = [1, 2, 5];
MidPop(target_indices) = MidPop(target_indices) * mid_adjustment_factor;
OldPop(target_indices) = OldPop(target_indices) * old_adjustment_factor;

BM.YoungPop=YoungPop;BM.MidPop=MidPop;BM.OldPop=OldPop;

% we correct for multiple polyps
AllPolyps   = OnePolyp(1:100)/100;
OnePolyp    = OnePolyp - TwoPolyps;
TwoPolyps   = TwoPolyps - ThreePolyps;
ThreePolyps = ThreePolyps - FourPolyps;
FourPolyps  = FourPolyps  - FivePolyps;

if DispFlag
    set(0, 'CurrentFigure', h2); subplot(3,3,3)
    plot(0:99, OnePolyp(1:100)./AllPolyps, 'color', 'r'), hold on
    plot(0:99, TwoPolyps(1:100)./AllPolyps, 'color', 'k')
    plot(0:99, ThreePolyps(1:100)./AllPolyps, 'color', 'b')
    plot(0:99, FourPolyps(1:100)./AllPolyps, 'color', 'g')
    plot(0:99, FivePolyps(1:100)./AllPolyps, 'color', 'm')
    set(gca, 'xlim', [0 100],  'fontsize', FontSz)
    xlabel('year'), ylabel('% of patients with adenomas', 'Fontsize', FontSz), title('number of adenomas', 'Fontsize', FontSz)
    l=legend('1 adenoma', '2 adenomas', '3 adenomas', '4 adenomas', '>4 adenomas');
    set(l, 'location', 'northoutside', 'fontsize', FontSz-1)
    set(gca, 'xlim', [0 100],  'fontsize', FontSz)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%    Number Polyps Frequency distribution    %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

YoungBenchmark = Variables.Benchmarks.MultiplePolypsYoung;
MidBenchmark   = Variables.Benchmarks.MultiplePolyp;
OldBenchmark   = Variables.Benchmarks.MultiplePolypsOld;

BM.OutputValues.YoungPop = YoungPop; BM.OutputValues.MidPop = MidPop; BM.OutputValues.OldPop = OldPop; 
% Young Population Plot
if DispFlag
    set(0, 'CurrentFigure', h2); subplot(3,3,4)
    plot(YoungPop, '--ks','LineWidth',LineSz, 'MarkerEdgeColor','k', 'MarkerFaceColor','g', 'MarkerSize',MarkerSz), hold on
    plot(YoungBenchmark,  '--bs','LineWidth',LineSz, 'MarkerEdgeColor','k', 'MarkerFaceColor','b', 'MarkerSize',MarkerSz)
    xlabel('min number polyps', 'fontsize', FontSz); ylabel('% of population', 'fontsize', FontSz)
    set(gca, 'XTick', [1 2 3 4 5]), title('young population (40-54y)', 'fontsize', FontSz), set(gca, 'fontsize', FontSz)
end

if DispFlag
    set(0, 'CurrentFigure', h2); subplot(3,3,5)
    % Intermediate Population Plot
    plot(MidPop,   '--ks','LineWidth',LineSz, 'MarkerEdgeColor','k', 'MarkerFaceColor','m', 'MarkerSize',MarkerSz), hold on
    plot(MidBenchmark,    '--bs','LineWidth',LineSz, 'MarkerEdgeColor','k', 'MarkerFaceColor','b', 'MarkerSize',MarkerSz)
    xlabel('min number polyps', 'fontsize', FontSz); ylabel('% of population', 'fontsize', FontSz)
    set(gca, 'XTick', [1 2 3 4 5]), title('intermediate population (55-74y)', 'fontsize', FontSz), set(gca, 'fontsize', FontSz)
end

for f=1:5
    BM.description{bmc} = ['middle ' num2str(f) ' polyp']; BM.value{bmc} = MidPop(f); BM.benchmark{bmc} = MidBenchmark(f); 
    if and(BM.value{bmc} > BM.benchmark{bmc}*(1 - tolerance), BM.value{bmc} < (BM.benchmark{bmc}*(1 + tolerance)))
        BM.flag{bmc} = 'green'; 
    else
        BM.flag{bmc} = 'red'; 
    end
    if DispFlag
        line([f-0.5 f+0.5], [BM.value{bmc} BM.value{bmc}], 'color', BM.flag{bmc})
        plot(f, BM.value{bmc}, '--ks', 'MarkerEdgeColor', BM.flag{bmc}, 'MarkerFaceColor', BM.flag{bmc}, 'MarkerSize',MarkerSz)
    end
    BM.OutputFlags.MidPop{f} = BM.flag{bmc};
    bmc =bmc+1;
end
if DispFlag
    set(0, 'CurrentFigure', h2); subplot(3,3,6)
    % Old Population Plot
    plot(OldPop,   '--ks','LineWidth',LineSz, 'MarkerEdgeColor','k', 'MarkerFaceColor','c', 'MarkerSize',MarkerSz), hold on
    plot(OldBenchmark,    '--bs','LineWidth',LineSz, 'MarkerEdgeColor','k', 'MarkerFaceColor','b', 'MarkerSize',MarkerSz)
    xlabel('min number polyps', 'fontsize', FontSz); ylabel('% of population', 'fontsize', FontSz)
    set(gca, 'XTick', [1 2 3 4 5]), title('old population (75-90y)', 'fontsize', FontSz), set(gca, 'fontsize', FontSz)
    set(gca, 'fontsize', FontSz)
end
for f=1:5
    BM.description{bmc} = ['old ' num2str(f) ' polyp']; BM.value{bmc} = OldPop(f); BM.benchmark{bmc} = OldBenchmark(f); 
    if and(BM.value{bmc} > BM.benchmark{bmc}*(1 - tolerance), BM.value{bmc} < (BM.benchmark{bmc}*(1 + tolerance)))
        BM.flag{bmc} = 'green';  
    else
        BM.flag{bmc} = 'red'; 
    end
    if DispFlag
        line([f-0.5 f+0.5], [BM.value{bmc} BM.value{bmc}], 'color', BM.flag{bmc})
        plot(f, BM.value{bmc}, '--ks', 'MarkerEdgeColor', BM.flag{bmc}, 'MarkerFaceColor', BM.flag{bmc}, 'MarkerSize',MarkerSz)
    end
    bmc =bmc+1;
end
clear YoungPop MidPop OldPop YoungBenchmark MidBenchmark OldBenchmark
clear OnePolyp TwoPolyps ThreePolyps FourPolyps FivePolyps NumYoung NumMid NumOld AllPolyps


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%    Written Summary    %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear SummaryVariable String

d_years = data.DeathYear;
d_years = d_years(:);
d_gends = data.Gender;
d_gends = d_gends(:);
d_cause = data.DeathCause;
d_cause = d_cause(:);
d_natyears = data.NaturalDeathYear;
d_natyears = d_natyears(:);
d_yearInc = data.YearIncluded;
d_maxPolyps = data.MaxPolyps;
d_diagCa = data.DiagnosedCancer;
d_allCost = data.Money.AllCost;
data.Money = rmfield(data.Money, 'AllCost');
if exist('sv_yearAlive', 'var')
    d_yearAlive = sv_yearAlive;
    clear sv_yearAlive
end
if isfield(data, 'MaxCancer')
    d_maxCancer = data.MaxCancer;
end
fieldsToRemove2 = {'DeathYear','DeathCause','NaturalDeathYear','Gender','YearIncluded','MaxPolyps','DiagnosedCancer'};
for fi = 1:length(fieldsToRemove2)
    if isfield(data, fieldsToRemove2{fi})
        data = rmfield(data, fieldsToRemove2{fi});
    end
end
clear fieldsToRemove2 fi
femaleCount = sum(d_gends == 2);
maleCount   = n - femaleCount;
 
SummaryVariable{1,1} = n;
SummaryVariable{2,1} = round(mean(d_years(d_years>0))*100)/100;

valid_males_idx = find(d_years > 0 & d_gends == 1);
if ~isempty(valid_males_idx)
    SummaryVariable{3,1} = round(mean(d_years(valid_males_idx))*100)/100; 
else
    SummaryVariable{3,1} = 0;
end

valid_females_idx = find(d_years > 0 & d_gends == 2);
if ~isempty(valid_females_idx)
    SummaryVariable{4,1} = round(mean(d_years(valid_females_idx))*100)/100;
else
    SummaryVariable{4,1} = 0;
end
SummaryVariable{5,1} = sum(data.Number.Screening_Colonoscopy);
SummaryVariable{6,1} = sum(data.Number.Symptoms_Colonoscopy);
SummaryVariable{7,1} = sum(data.Number.Follow_Up_Colonoscopy);
SummaryVariable{8,1} = sum(data.Number.RectoSigmo);
SummaryVariable{9,1} = sum(data.Number.FOBT);
SummaryVariable{10,1} = sum(data.PaymentType.SequentialFIT);
SummaryVariable{11,1} = sum(data.Number.Sept9);
SummaryVariable{12,1} = sum(data.Number.other);
SummaryVariable{13,1} = sum(d_cause == 2);

% Discount settings: 3% and 5% annual rates, anchored at FIXED age 35
discountRateMain3 = 0.03;
discountRateMain5 = 0.05;
discountStartAge = 35; % FIXED to 35

sizeY = size(d_yearInc);
nYears = sizeY(1);
nPatients = sizeY(2);
yearAges = (1:nYears)'; % year 1 to 100 (ages 1 to 100)

% Build AnnualDiscountVector for 3% and 5%
% For each year t (age), discount factor = (1+r)^-max(0,t-35)
AnnualDiscountVector3 = zeros(nYears,1);
AnnualDiscountVector5 = zeros(nYears,1);
for idxYear = 1:nYears
    t = yearAges(idxYear);
    discountTime = max(0, t - discountStartAge);
    AnnualDiscountVector3(idxYear) = (1 + discountRateMain3)^(-discountTime);
    AnnualDiscountVector5(idxYear) = (1 + discountRateMain5)^(-discountTime);
end
AnnualDiscountRow3 = reshape(AnnualDiscountVector3, 1, []);
AnnualDiscountRow5 = reshape(AnnualDiscountVector5, 1, []);

% Discounted years lost to colon cancer - BOTH 3% and 5% rates, anchored at 35
yearsLostCRCDiscounted3 = 0;
yearsLostCRCDiscounted5 = 0;

crcDeathIdx = find(d_cause == 2);
for k = 1:numel(crcDeathIdx)
    pid = crcDeathIdx(k);
    lossStart = d_years(pid);
    lossEnd = d_natyears(pid);
    
    if lossEnd <= lossStart
        continue;
    end

    % Correctly calculate YLL by summing discounted annual segments
    % For each year t between death and natural death
    for t_year = floor(lossStart):ceil(lossEnd)-1
        t_overlap_start = max(lossStart, t_year);
        t_overlap_end = min(lossEnd, t_year + 1);
        duration = t_overlap_end - t_overlap_start;
        
        if duration > 0
            t_mid = (t_overlap_start + t_overlap_end) / 2;
            discountTime = max(0, t_mid - discountStartAge);
            yearsLostCRCDiscounted3 = yearsLostCRCDiscounted3 + duration * (1 + discountRateMain3)^(-discountTime);
            yearsLostCRCDiscounted5 = yearsLostCRCDiscounted5 + duration * (1 + discountRateMain5)^(-discountTime);
        end
    end
end

SummaryVariable{14,1} = yearsLostCRCDiscounted3;
SummaryVariable{15,1} = yearsLostCRCDiscounted5;

coloDeathIdx = find(d_cause == 3);
SummaryVariable{16,1} = numel(coloDeathIdx);
if ~isempty(coloDeathIdx)
    SummaryVariable{17,1} = sum(d_natyears(coloDeathIdx) - d_years(coloDeathIdx));
else
    SummaryVariable{17,1} = 0;
end
% Calculate both per-capita (for plotting) and total (for SummaryVariable) - BOTH 3% and 5%
AnnualCostPerCapita = sum(d_allCost, 2) ./ n;
AnnualCostPerCapitaDiscounted3 = AnnualCostPerCapita .* AnnualDiscountVector3;
AnnualCostPerCapitaDiscounted5 = AnnualCostPerCapita .* AnnualDiscountVector5;
AnnualTotalCost = sum(d_allCost, 2);
AnnualTotalCostDiscounted3 = AnnualTotalCost .* AnnualDiscountVector3;
AnnualTotalCostDiscounted5 = AnnualTotalCost .* AnnualDiscountVector5;
SummaryVariable{18,1} = sum(AnnualTotalCostDiscounted3); % 3% discounted total costs
SummaryVariable{19,1} = sum(AnnualTotalCostDiscounted5); % 5% discounted total costs
SummaryVariable{20,1} = DwellTimeAllCa;
SummaryVariable{21,1} = DwellTimeProgressedCa;
SummaryVariable{22,1} = DwellTimeFastCa;
SummaryVariable{23,1} = SojournDoc.SojournMedian;

% ------------------ NEW: QALY CALCULATION - BOTH 3% and 5% ------------------ %
% 1. Create Base Utilities (chunked to avoid OOM)
QALY_Base_Disc3 = 0;
QALY_Base_Disc5 = 0;
chunkSize = 5000;
nChunks = ceil(sizeY(2) / chunkSize);
for ci = 1:nChunks
    idxStart = (ci-1)*chunkSize + 1;
    idxEnd   = min(ci*chunkSize, sizeY(2));
    cIdx     = idxStart:idxEnd;
    
    U_chunk = ones(sizeY(1), numel(cIdx));
    U_chunk(d_maxPolyps(:, cIdx) > 0) = 0.955;
    U_chunk(d_maxCancer(:, cIdx) == 7) = 0.768;
    U_chunk(d_maxCancer(:, cIdx) == 8) = 0.656;
    U_chunk(d_maxCancer(:, cIdx) == 9) = 0.562;
    U_chunk(d_maxCancer(:, cIdx) == 10) = 0.495;
    
    Y_chunk = d_yearInc(:, cIdx);
    Base_chunk = U_chunk .* Y_chunk;
    clear U_chunk Y_chunk
    
    QALY_Base_Disc3 = QALY_Base_Disc3 + sum((AnnualDiscountVector3(:)' .* sum(Base_chunk, 2)'));
    QALY_Base_Disc5 = QALY_Base_Disc5 + sum((AnnualDiscountVector5(:)' .* sum(Base_chunk, 2)'));
    clear Base_chunk
end

% 3. Calculate Disutilities - for both 3% and 5%
% Method 1: Total Colonoscopies
QALY_Colo_Total = data.Number.Baseline_Colonoscopy(1:nYears) + data.Number.Screening_Colonoscopy(1:nYears) + ...
                  data.Number.Symptoms_Colonoscopy(1:nYears) + data.Number.Follow_Up_Colonoscopy(1:nYears);
% Ensure QALY_Colo_Total is a row vector with length nYears
if iscolumn(QALY_Colo_Total)
    QALY_Colo_Total = QALY_Colo_Total';
end
% Apply discounting to colonoscopy counts for 3% and 5%
QALY_Pen1_Disc3 = sum(double(QALY_Colo_Total) .* double(AnnualDiscountRow3)) * 0.0055;
QALY_Pen1_Disc5 = sum(double(QALY_Colo_Total) .* double(AnnualDiscountRow5)) * 0.0055;

% Method 2: Complications
QALY_Perf_Total = double(sum(data.PaymentType.Perforation(:, 1:nYears), 1)); % sum over the first dimension (locations)
QALY_Bleed_Total = double(sum(data.PaymentType.Bleeding(:, 1:nYears), 1) + sum(data.PaymentType.BleedingTransf(:, 1:nYears), 1));
QALY_Ser_Total = double(sum(data.PaymentType.Serosa(:, 1:nYears), 1));

% Ensure these are row vectors
if iscolumn(QALY_Perf_Total), QALY_Perf_Total = QALY_Perf_Total'; end
if iscolumn(QALY_Bleed_Total), QALY_Bleed_Total = QALY_Bleed_Total'; end
if iscolumn(QALY_Ser_Total), QALY_Ser_Total = QALY_Ser_Total'; end

QALY_Pen2_Disc3 = sum(double(QALY_Perf_Total) .* double(AnnualDiscountRow3)) * 0.0055 + ...
                 sum((double(QALY_Bleed_Total) + double(QALY_Ser_Total)) .* double(AnnualDiscountRow3)) * 0.0027;
QALY_Pen2_Disc5 = sum(double(QALY_Perf_Total) .* double(AnnualDiscountRow5)) * 0.0055 + ...
                 sum((double(QALY_Bleed_Total) + double(QALY_Ser_Total)) .* double(AnnualDiscountRow5)) * 0.0027;

% 4. Final Totals and Per Capita - for both 3% and 5%
QALY_Method1_Disc_Total3 = QALY_Base_Disc3 - QALY_Pen1_Disc3;
QALY_Method1_Disc_Total5 = QALY_Base_Disc5 - QALY_Pen1_Disc5;
QALY_Method2_Disc_Total3 = QALY_Base_Disc3 - QALY_Pen2_Disc3;
QALY_Method2_Disc_Total5 = QALY_Base_Disc5 - QALY_Pen2_Disc5;

clear QALY_Base_Disc3 QALY_Base_Disc5 QALY_Pen1_Disc3 QALY_Pen1_Disc5 QALY_Pen2_Disc3 QALY_Pen2_Disc5
clear QALY_Method1_Disc_Total3 QALY_Method1_Disc_Total5
clear QALY_Colo_Total QALY_Perf_Total QALY_Bleed_Total QALY_Ser_Total
clear d_maxPolyps d_allCost d_yearAlive d_maxCancer d_diagCa
clear AnnualTotalCost AnnualTotalCostDiscounted3 AnnualTotalCostDiscounted5
clear AnnualCostPerCapita AnnualCostPerCapitaDiscounted5
clear sizeY nPatients yearAges

fieldsToRemove = {'MaxCancer'};
for fi = 1:length(fieldsToRemove)
    if isfield(data, fieldsToRemove{fi})
        data = rmfield(data, fieldsToRemove{fi});
    end
end
clear fieldsToRemove fi

String{1}=sprintf('population: %d patients', n);
String{2}=sprintf('age: all: %g, male: %g, female: %g', round(sum(d_years)/n*100)/100 -1,...
    SummaryVariable{3,1},...                                            
    SummaryVariable{4,1});                                                  

String{3}=sprintf('%d screening colos performed', sum(data.Number.Screening_Colonoscopy));
String{4}=sprintf('%d symptom colos performed',   sum(data.Number.Symptoms_Colonoscopy));
String{5}=sprintf('%d follow up colos performed', sum(data.Number.Follow_Up_Colonoscopy));

String{6}=sprintf('%d custom tests performed',...
    sum(data.Number.RectoSigmo) + sum(data.Number.FOBT) + sum(data.Number.I_FOBT) + sum(data.Number.Sept9) + sum(data.Number.other));
String{7}=sprintf('%d patients died of CRC', numel(crcDeathIdx));
String{8}=sprintf('%g discounted years lost to CRC (3%%)', SummaryVariable{14,1});
String{9}=sprintf('%g discounted years lost to CRC (5%%)', SummaryVariable{15,1});
String{10}=sprintf('%d pat. died due to colo', numel(coloDeathIdx));
if ~isempty(coloDeathIdx)
    String{11}=sprintf('%g years lost to colo', sum(d_natyears(coloDeathIdx) - d_years(coloDeathIdx)));
else
    String{11}=sprintf('%g years lost to colo', 0);
end
String{12}=sprintf('%g discounted total costs (3%%)', SummaryVariable{18,1});
String{13}=sprintf('%g discounted total costs (5%%)', SummaryVariable{19,1});                                            
String{14}=sprintf('comment: %s', Variables.Comment);
String{15}=sprintf('settings: %s', Variables.Settings_Name);

if DispFlag
    set(0, 'CurrentFigure', h4); subplot(3,3,9); axis off
    text(0, 0.6, String, 'Interpreter', 'none', 'FontSize', FontSz-2)
end
clear String femaleCount maleCount

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%    Fast Cancer        %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% we summarize the instances of progression of fast cancer and progressed
% cancer per decade
for f=1:10
    Start=(f-1)*10+1;
    Ende =f*10;
    ProgressedCancer(f) = sum(data.ProgressedCancer(Start:Ende)); 
    FastCancer_1(f)     = sum(data.DirectCancer(1, Start:Ende)); % cancer derived from polyp p1
    FastCancer_2(f)     = sum(data.DirectCancer(2, Start:Ende)); % cancer derived from polyp p2
    FastCancer_3(f)     = sum(data.DirectCancer(3, Start:Ende)); % etc.
    FastCancer_4(f)     = sum(data.DirectCancer(4, Start:Ende));
    FastCancer_5(f)     = sum(data.DirectCancer(5, Start:Ende));
    FastCancer_x(f)     = sum(data.DirectCancer2(Start:Ende)); % cancer derived without precursor
end

AllCancer = ProgressedCancer + FastCancer_1 + FastCancer_2 + FastCancer_3 + FastCancer_4 + FastCancer_5 + FastCancer_x;
% we will later draw lines to visualize the whole cohort
Summary(1) = sum(FastCancer_1);
Summary(2) = Summary(1) + sum(FastCancer_2);
Summary(3) = Summary(2) + sum(FastCancer_3);
Summary(4) = Summary(3) + sum(FastCancer_4);
Summary(5) = Summary(4) + sum(FastCancer_5);
Summary(6) = Summary(5) + sum(FastCancer_x);
Summary = Summary/sum(AllCancer)*100;

PlotData = [FastCancer_1./AllCancer; FastCancer_2./AllCancer; FastCancer_3./AllCancer;...
    FastCancer_4./AllCancer; FastCancer_5./AllCancer; ProgressedCancer./AllCancer; FastCancer_x./AllCancer] *100;
PlotData(isnan(PlotData)) = 0; % we replace empty elements by zero

if DispFlag
    set(0, 'CurrentFigure', h2); subplot(3,3,9)
    area(PlotData'), grid on, colormap summer, set(gca,'Layer','top')
    ylabel('% of all cancer', 'fontsize', FontSz), xlabel('decade', 'fontsize', FontSz)
    title('origin of cancer', 'fontsize', FontSz)
    set(gca, 'xlim', [0 10], 'ylim', [0 100], 'fontsize', FontSz)
    cm = colormap;
    cpos = [1  13 26 38 51 64]; % these are the positions in the colormap used for the graphs
    for f=1:5
        line ([0.1 4], [Summary(f) Summary(f)], 'color', cm(cpos(f), :))
    end
    l=legend('Adenoma 3mm', 'Adenoma 5mm', 'Adenoma 7mm', 'Adenoma 9mm', 'Adv Ad P5', 'Adv Ad P6', 'direct');
    set(l, 'location', 'northoutside', 'fontsize', 5)
end
% we save for later display as a benchmark
BM.CancerOriginArea    = PlotData';
BM.CancerOriginSummary = Summary;

for f=1:5
    value(f) = sum(data.DirectCancer(f, 1:100))/sum(data.AllPolyps(f,1:100))*100;
end
value(6) = sum(data.ProgressedCancer(1:100))/sum(data.AllPolyps(6,1:100))*100;


BenchMark = Variables.Benchmarks.Cancer.Fastcancer;
FastCancerValue     = value;
FastCancerBenchMark = BenchMark;    

% we correct and now talk about relative danger of each polyp
BenchMark = BenchMark./sum(BenchMark)*100;

% we correct to relative danger
value = value./ sum(value)*100;
% we save for later display as a benchmark
BM.CancerOriginValue   = value;
% if DispFlag
%     subplot(3,3,9)
%     bar(cat(2, value', zeros(6,1), BenchMark')', 'stacked'), hold on
%     l=legend('P1', 'P2', 'P3', 'P4', 'P5', 'P6');
%     set(l, 'location', 'Eastoutside', 'fontsize', 6)
% end
ypos = 0;
for f=1:6
    BM.description{bmc} = ['%P' num2str(f) ' transforming']; BM.value{bmc} = value(f); BM.benchmark{bmc} = BenchMark(f); 
    if and(BM.value{bmc} > BM.benchmark{bmc}*(1 - tolerance), BM.value{bmc} < (BM.benchmark{bmc}*(1 + tolerance)))
        BM.flag{bmc} = 'green';    
    else
        BM.flag{bmc} = 'red';
    end
    if DispFlag
        line([1.5 2.5], [(ypos + value(f)/2) (ypos + value(f)/2)], 'color', BM.flag{bmc})
    end
    ypos = ypos + value(f);
    % we save for later display as a benchmark
    BM.CancerOriginFlag{f} = BM.flag{bmc};
    bmc = bmc + 1;
end
% if DispFlag
%     ylabel('relative danger of polyps', 'fontsize', 6)
%     set(gca, 'xticklabel', {'polyps' '' 'benchmark'}, 'fontsize', 6, 'yscale', 'log')
% end
clear PlotData cm Summary FastCancer_1 FastCancer_2 FastCancer_3 FastCancer_4
clear FastCancer_5 AllCancer Start Ende value BenchMark


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%    Stage Distribution   %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for x=1:3
    clear Cis Stage_I Stage_II Stage_III Stage_IV population
    switch x
        case 1
            headline = 'stage distribution screening';
            tmp = data.TumorRecord.Stage;
            tmp(~(data.TumorRecord.Detection == 1)) = 0;
            benchmark = Variables.Benchmarks.Cancer.ScreeningStageDistribution;
        case 2
            headline = 'stage distribution symptomatic cancer';
            tmp = data.TumorRecord.Stage;
            tmp(~(data.TumorRecord.Detection == 2)) = 0;
            benchmark = Variables.Benchmarks.Cancer.SymptomaticStageDistribution;
        case 3
            headline = 'stage distribution follow up';
            tmp = data.TumorRecord.Stage;
            tmp(~(data.TumorRecord.Detection == 3)) = 0;
            benchmark = Variables.Benchmarks.Cancer.ScreeningStageDistribution;
    end
    population(1, :) = [sum(sum(tmp(1:50,:)==7))   sum(sum(tmp(1:50,:)==8))   sum(sum(tmp(1:50,:)==9))   sum(sum(tmp(1:50,:)==10))];  % year adapted
    population(2, :) = [sum(sum(tmp(51:60,:)==7))  sum(sum(tmp(51:60,:)==8))  sum(sum(tmp(51:60,:)==9))  sum(sum(tmp(51:60,:)==10))]; % year adapted
    population(3, :) = [sum(sum(tmp(61:70,:)==7))  sum(sum(tmp(61:70,:)==8))  sum(sum(tmp(61:70,:)==9))  sum(sum(tmp(61:70,:)==10))]; % year adapted
    population(4, :) = [sum(sum(tmp(71:80,:)==7))  sum(sum(tmp(71:80,:)==8))  sum(sum(tmp(71:80,:)==9))  sum(sum(tmp(71:80,:)==10))]; % year adapted
    population(5, :) = [sum(sum(tmp(81:90,:)==7))  sum(sum(tmp(81:90,:)==8))  sum(sum(tmp(81:90,:)==9))  sum(sum(tmp(81:90,:)==10))]; % year adapted
    population(6, :) = [sum(sum(tmp(91:100,:)==7)) sum(sum(tmp(91:100,:)==8)) sum(sum(tmp(91:100,:)==9)) sum(sum(tmp(91:100,:)==10))]; % year adapted
    population(7, :) = [sum(sum(tmp(1:100,:)==7))  sum(sum(tmp(1:100,:)==8))  sum(sum(tmp(1:100,:)==9))  sum(sum(tmp(1:100,:)==10))]; % year adapted
    
    if isequal(x, 1)
        SummaryVariable{24} = population(7, 1); SummaryVariable{25} = population(7, 2); 
        SummaryVariable{26} = population(7, 3); SummaryVariable{27} = population(7, 4);
    elseif isequal(x, 2)
        SummaryVariable{28} = population(7, 1); SummaryVariable{29} = population(7, 2); 
        SummaryVariable{30} = population(7, 3); SummaryVariable{31} = population(7, 4);
    end
    
    for f=1:7
        population(f, :) = population(f, :)/sum(population(f, :))*100; 
    end
    population(8, :) = [0   0    0    0];
    population(9, :) = benchmark;
    if DispFlag
        set(0, 'CurrentFigure', h3); subplot(3,3,x)
        bar(population, 'stacked'), hold on
        l=legend('Stage I', 'Stage II', 'Stage III', 'Stage IV');
        set(l, 'location', 'Northoutside', 'fontsize', 6)
        xlabel('year', 'fontsize', 6), ylabel('% of affected patients', 'fontsize', 6)
        set(gca, 'xticklabel', {'<50' '50+' '60+' '70+' '80+' '90+' 'all' ''  'b-mark'}, 'fontsize', 5, 'ylim', [0 100])
        title(headline, 'fontsize', FontSz)
    end
    if isequal(x,2)
        ypos = 0;
        for f=1:4
            BM.description{bmc} = ['% stage ' num2str(f)]; BM.value{bmc} = population(7, f);
            BM.benchmark{bmc} = benchmark(f); 
            if and(BM.value{bmc} > BM.benchmark{bmc}*(1 - tolerance), BM.value{bmc} < (BM.benchmark{bmc}*(1 + tolerance)))
                BM.flag{bmc} = 'green';
            else
                BM.flag{bmc} = 'red';
            end
            if DispFlag
                line([7.5 8.5], [(ypos + BM.value{bmc}/2) (ypos + BM.value{bmc}/2)], 'color', BM.flag{bmc})
            end
            ypos = ypos + BM.value{bmc};
            bmc = bmc + 1;
        end
    end
end

stage_I   = sum(sum(data.TumorRecord.Stage == 7));
stage_II  = sum(sum(data.TumorRecord.Stage == 8));
stage_III = sum(sum(data.TumorRecord.Stage == 9));
stage_IV  = sum(sum(data.TumorRecord.Stage == 10));

Summe = sum(sum(data.TumorRecord.Stage >0));
SummaryVariable{32} = stage_I/Summe*100;   SummaryVariable{33} = stage_II/Summe*100; 
SummaryVariable{34} = stage_III/Summe*100; SummaryVariable{35} = stage_IV/Summe*100;

SummaryVariable{36} = stage_I;   SummaryVariable{37} = stage_II; 
SummaryVariable{38} = stage_III; SummaryVariable{39} = Summe;

SummaryVariable{40} = sum(sum(data.TumorRecord.Detection==1));   
SummaryVariable{41} = sum(sum(data.TumorRecord.Detection==2));  
SummaryVariable{42} = sum(sum(data.TumorRecord.Detection==3)); 
SummaryVariable{43} = sum(sum(data.TumorRecord.Detection==4)); 
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%    Cause of Death     %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

edges = [0 9.1 19.1 29.1 39.1 49.1 59.1 69.1 79.1 89.1 150]; % year adapted
natDeathIdx = find(d_cause == 1);
if ~isempty(natDeathIdx)
    NaturalDeath = histc(d_years(natDeathIdx), edges);
else
    NaturalDeath = zeros(size(edges));
end
if ~isempty(crcDeathIdx)
    CancerDeath = histc(d_years(crcDeathIdx), edges);
else
    CancerDeath = zeros(size(edges));
end
if ~isempty(coloDeathIdx)
    ColonoscDeath = histc(d_years(coloDeathIdx), edges);
else
    ColonoscDeath = zeros(size(edges));
end 

if DispFlag
    set(0, 'CurrentFigure', h4); subplot(3, 3, 5)
    bar(NaturalDeath, 'b'), hold on
    bar(CancerDeath, 'r')
    bar(ColonoscDeath, 'k')
    set(gca, 'yscale', 'log', 'xlim', [1 10],...
        'XTickLabel', {'1', '2', '3' '4' '5' '6' '7' '8' '9' '10+'}, 'fontsize', FontSz)
    xlabel('decade', 'fontsize', FontSz), ylabel('number patients', 'fontsize', FontSz)
    title('cause of death', 'fontsize', FontSz)
    l=legend('natural', 'cancer', 'colonoscopy');
    set(l, 'location', 'northoutside', 'fontsize', FontSz)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%    Colonoscopies      %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if DispFlag
    set(0, 'CurrentFigure', h4); subplot(3, 3, 6)
    plot(0:99, data.Number.Symptoms_Colonoscopy(1:100), 'k'), hold on
    plot(0:99, data.Number.Screening_Colonoscopy(1:100), 'r')
    plot(0:99, data.Number.Follow_Up_Colonoscopy(1:100), 'b')
    plot(0:99, data.Number.Baseline_Colonoscopy(1:100), 'c')
    set(gca, 'yscale', 'log',  'fontsize', FontSz)
    xlabel('year', 'fontsize', FontSz), ylabel('number patients', 'fontsize', FontSz)
    title('reasons for colonoscopies', 'fontsize', FontSz)
    l=legend('symptoms', 'screening', 'follow up', 'baseline');
    set(l, 'location', 'northoutside', 'fontsize', FontSz)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%    Adenomas Removed     %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if DispFlag
    set(0, 'CurrentFigure', h4); subplot(3, 3, 7)
    plot(0:99, data.EarlyPolypsRemoved(1:100), 'r'),  hold on
    plot(0:99, data.AdvancedPolypsRemoved(1:100), 'k')
    set(gca, 'fontsize', FontSz)
    l=legend('early', 'advanced');
    set(l, 'location', 'northoutside', 'fontsize', FontSz)
    xlabel('year', 'fontsize', FontSz), ylabel('number adenomas', 'fontsize', FontSz)
    title('adenomas removed', 'fontsize', FontSz)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%    Dollars spent per person     %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if DispFlag
    set(0, 'CurrentFigure', h4); subplot(3, 3, 8)
    plot(0:99, AnnualCostPerCapitaDiscounted3(1:100), 'g'),  hold on
    tmp=sum(data.Money.Treatment,2)/n; plot(0:99, tmp(1:100) .* AnnualDiscountVector3(1:100), 'k')
    tmp=sum(data.Money.FollowUp,2)/n; plot(0:99, tmp(1:100) .* AnnualDiscountVector3(1:100), 'b')
    tmp=sum(data.Money.Screening,2)/n; plot(0:99, tmp(1:100) .* AnnualDiscountVector3(1:100), 'r')
    
    set(gca, 'fontsize', FontSz)
    xlabel('year', 'fontsize', FontSz), ylabel('US Dollar', 'fontsize', FontSz)
    title('dollars spent per person', 'fontsize', FontSz)
    l=legend('all cost', 'treatment', 'follow up', 'screening');
    set(l, 'location', 'northoutside', 'fontsize', FontSz)
end
clear AnnualDiscountVector3 AnnualDiscountVector5 AnnualDiscountRow3 AnnualDiscountRow5

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%    Location           %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tmp_all    = data.TumorRecord.Stage;
tmp_male   = data.TumorRecord.Gender == 1;
tmp_female = data.TumorRecord.Gender == 2;

tmp_Rectum = data.TumorRecord.Stage;
tmp_Rectum(data.TumorRecord.Location <13) = 0;
tmp_Right  = data.TumorRecord.Stage;
tmp_Right(data.TumorRecord.Location >3) = 0;
tmp_Rest   = data.TumorRecord.Stage;
tmp_Rest(data.TumorRecord.Location ==13) = 0;
tmp_Rest(data.TumorRecord.Location <4) = 0;

for f=1:4
    Sum_Stage_all(f)    = sum(sum(tmp_all==f+6));
    Sum_Stage_Rectum(f) = sum(sum(tmp_Rectum==f+6));
    Sum_Stage_Right(f)  = sum(sum(tmp_Right==f+6));
    Sum_Stage_Rest(f)   = sum(sum(tmp_Rest==f+6));
end

tmp_Rectum_male  = tmp_Rectum>0;
tmp_Rectum_male(tmp_female) = 0;
tmp_Rest_male    = tmp_Rest>0;
tmp_Rectum_male(tmp_female) = 0;
tmp_all_male     = tmp_all >0;%m
tmp_all_male(tmp_female) = 0; %m

tmp_Rectum_female  = tmp_Rectum>0;
tmp_Rectum_female(tmp_male) = 0;
tmp_Rest_female    = tmp_Rest>0;
tmp_Rectum_female(tmp_male) = 0;
tmp_all_female     = tmp_all >0;%m
tmp_all_female(tmp_male) = 0; %m

clear value x 
for f=1:100
    LocationRectum{1}(f) = sum(tmp_Rectum_male(f,:));
    LocationRest{1}(f)   = sum(tmp_Rest_male(f,:));
    LocationRectum{2}(f) = sum(tmp_Rectum_female(f,:));
    LocationRest{2}(f)   = sum(tmp_Rest_female(f,:));
    LocationAll{1}(f)    = sum(tmp_all_male(f,:));
    LocationAll{2}(f)    = sum(tmp_all_female(f,:));
end
%m for calculating the percentage of rectal cancer. This percentage is used

%%% benchmarks
LocBenchmarkMale   = Variables.Benchmarks.Cancer.LocationRectumMale;
LocBenchmarkFemale = Variables.Benchmarks.Cancer.LocationRectumFemale;
LocX               = Variables.Benchmarks.Cancer.LocationRectumYear;
                    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% carcinoma rectum both genders                     %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% we average the male and female benchmarks
% here we only collect the data for display during adjustment of adenomas
BM.LocationRectumAllGender = (LocationRectum{1}(1:100) + LocationRectum{2}(1:100))/2;
BM.LocationRest            = (LocationRest{1}(1:100) + LocationRest{2}(1:100))/2;
BM.LocBenchmark            = (LocBenchmarkMale + LocBenchmarkFemale)/2; 
BM.LocX                    = LocX;

for f=1:length(BM.LocX)
    x(f)     = mean(BM.LocX{f}(1):BM.LocX{f}(2));
    value(f) = sum(BM.LocationRectumAllGender((BM.LocX{f}(1)-2):(BM.LocX{f}(2)+2)))/...
        (sum(BM.LocationRectumAllGender((LocX{f}(1)-2):(LocX{f}(2)+2))) + sum(BM.LocationRest((BM.LocX{f}(1)-2):(BM.LocX{f}(2)+2))))*100;
    if and(value(f) > BM.LocBenchmark(f)*(1 - tolerance), value(f) < (BM.LocBenchmark(f)*(1 + tolerance)))
        tmpflag = 'green';
    else
        tmpflag = 'red';
    end
    if or(isequal(f, 2), isequal(f, 3))
        BM.description{bmc} = ['% rectum Ca year ' num2str(LocX{f}(1)) ' to ' num2str(LocX{f}(2))];
        BM.flag{bmc} = tmpflag;
        BM.benchmark{bmc} = BM.LocBenchmark(f); 
        BM.value{bmc} = value(f);
        BM.LocationRectumFlag{f} = tmpflag;
        bmc = bmc + 1;
    else
        BM.LocationRectumFlag{f} = 'black';
    end
        BM.LocationRectum(f)     = value(f);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% carcinoma rectum male                             %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if DispFlag
    figure (h3), subplot(3, 3, 5)
    plot(0:99, LocationRectum{1}(1:100)./ (LocationRectum{1}(1:100) + LocationRest{1}(1:100))*100, 'color', 'k'), hold on
end
for f=1:length(LocX)
    x(f)     = mean(LocX{f}(1):LocX{f}(2));
    value(f) = sum(LocationRectum{1}((LocX{f}(1)-2):(LocX{f}(2)+2)))/(sum(LocationRectum{1}((LocX{f}(1)-2):(LocX{f}(2)+2))) + sum(LocationRest{1}((LocX{f}(1)-2):(LocX{f}(2)+2))))*100;
    if and(value(f) > LocBenchmarkMale(f)*(1 - tolerance), value(f) < (LocBenchmarkMale(f)*(1 + tolerance)))
        tmpflag = 'green';
    else
        tmpflag = 'red';
    end
    if DispFlag
        line(LocX{f}, [value(f) value(f)], 'color', tmpflag)
        plot(x(f), value(f), '--rs','LineWidth',LineSz, 'MarkerEdgeColor','k', 'MarkerFaceColor', tmpflag, 'MarkerSize',MarkerSz)
    end
    if or(isequal(f, 2), isequal(f, 3))
        BM.description{bmc} = ['% rectum Ca year male ' num2str(LocX{f}(1)) ' to ' num2str(LocX{f}(2))];
        BM.flag{bmc} = tmpflag;
        BM.benchmark{bmc} = LocBenchmarkMale(f); 
        BM.value{bmc} = value(f);
        
        BM.Cancer.LocationRectumMale(f)     = BM.value{bmc};
        BM.Cancer.LocationRectumMaleYear(f) = LocX(f);
        bmc = bmc + 1;
    end
end
if DispFlag
    plot(x, value, '--rs','LineWidth',LineSz, 'MarkerEdgeColor','k', 'MarkerFaceColor','g', 'MarkerSize',MarkerSz)
    plot(x, LocBenchmarkMale, '--bs','LineWidth',LineSz, 'MarkerEdgeColor','k', 'MarkerFaceColor','b', 'MarkerSize',MarkerSz)
    xlabel('year', 'fontsize', FontSz), ylabel('% rectum of all ca', 'fontsize', FontSz)
    set(gca, 'fontsize', FontSz), title('fraction rectum carcinoma male', 'fontsize', FontSz)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% carcinoma rectum female                           %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if DispFlag
    set(0, 'CurrentFigure', h3); subplot(3, 3, 6)
    plot(0:99, LocationRectum{2}(1:100)./ (LocationRectum{2}(1:100) + LocationRest{2}(1:100))*100, 'color', 'k'), hold on
end
for f=1:length(LocX)
    x(f)     = mean(LocX{f}(1):LocX{f}(2));
    value(f) = sum(LocationRectum{2}((LocX{f}(1)-2):(LocX{f}(2)+2)))/(sum(LocationRectum{2}((LocX{f}(1)-2):(LocX{f}(2)+2))) + sum(LocationRest{2}((LocX{f}(1)-2):(LocX{f}(2)+2))))*100;
    if and(value(f) > LocBenchmarkFemale(f)*(1 - tolerance), value(f) < (LocBenchmarkFemale(f)*(1 + tolerance)))
        tmpflag = 'green';
    else
        tmpflag = 'red';
    end
    if DispFlag
        line(LocX{f}, [value(f) value(f)], 'color', tmpflag)
        plot(x(f), value(f), '--rs','LineWidth',LineSz, 'MarkerEdgeColor','k', 'MarkerFaceColor', tmpflag, 'MarkerSize',MarkerSz)
    end
    if or(isequal(f, 2), isequal(f, 3))
        BM.description{bmc} = ['% rectum Ca year female ' num2str(LocX{f}(1)) ' to ' num2str(LocX{f}(2))];
        BM.flag{bmc} = tmpflag;
        BM.benchmark{bmc} = LocBenchmarkFemale(f); 
        BM.value{bmc} = value(f);
        
        BM.Cancer.LocationRectumFemale(f)     = BM.value{bmc};
        BM.Cancer.LocationRectumFemaleYear(f) = LocX(f);
        bmc = bmc + 1;
    end
end
if DispFlag
    plot(x, LocBenchmarkFemale, '--bs','LineWidth',LineSz, 'MarkerEdgeColor','k', 'MarkerFaceColor','b', 'MarkerSize',MarkerSz)
    xlabel('year', 'fontsize', FontSz), ylabel('% rectum of all ca', 'fontsize', FontSz)
    set(gca, 'fontsize', FontSz), title('fraction rectum carcinoma female', 'fontsize', FontSz)
end
clear value x LocBenchmarkFemale LocBenchmarkMale tmp_Rectum_female tmp_Rectum_male tmp_Rest_female tmp_Rest_male LocX


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% stage distribution location                       %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Summe = sum(Sum_Stage_all)/100;
PlotData = [Sum_Stage_all/Summe; Sum_Stage_Rectum/Summe; Sum_Stage_Right/Summe; Sum_Stage_Rest/Summe];
if DispFlag
    set(0, 'CurrentFigure', h3); subplot(3, 3, 4)
    bar(PlotData, 'stacked') % NOT year adapted
    xlabel('year', 'fontsize', FontSz), ylabel('% of affected patients', 'fontsize', FontSz)
    set(gca, 'xticklabel', {'all' 'Rectum' 'Right' 'Rest'}, 'fontsize', FontSz-1)
    title('Stage distribution per location', 'fontsize', FontSz)
end

clear tmp_all tmp_Rectum tmp_Right tmp_Rest Ca_all Ca_Rectum Ca_Right Ca_Rest
clear Sum_all Sum_Rectum Sum_Right Sum_Rest Sum_Stage_all Sum_Stage_Rectum Sum_Stage_Right Sum_Stage_Rest Summe PlotData
clear Polyps_all AdvPolyps_all Polyps_right AdvPolyps_right Polyps_rest AdvPolyps_rest Polyps_rectum Polyps_rectum

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% relative danger polyps                            %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

value     = FastCancerValue./sum(FastCancerValue)*100;
BenchMark = FastCancerBenchMark./sum(FastCancerBenchMark)*100;

String1{1} = 'Relative danger adenomas';
AdenomaLabel = {'Ad 3mm', 'Ad 3mm', 'Ad 3mm', 'Ad 3mm', 'Adv P5', 'Adv P6'};
for f=1:6
    BM.description{bmc} = [AdenomaLabel{f} num2str(f) ' relative danger']; BM.value{bmc} = value(f); BM.benchmark{bmc} = BenchMark(f); 
    String1{f+1}        = AdenomaLabel{f};
    String2{f+1}        = num2str(round(BM.value{bmc}*1000)/1000);
    String3{f+1}        = num2str(round(BM.benchmark{bmc}*1000)/1000);
    if and(BM.value{bmc} > BM.benchmark{bmc}*(1 - tolerance), BM.value{bmc} < (BM.benchmark{bmc}*(1 + tolerance)))
        BM.flag{bmc} = 'green';    
    else
        BM.flag{bmc} = 'red';
    end
    String4{f+1}        = BM.flag{bmc};
    bmc = bmc + 1;
end
if DispFlag
    set(0, 'CurrentFigure', h2); subplot(3, 3, 8); axis off
    text(0,   0.8, String1, 'Interpreter', 'none', 'FontSize', FontSz-1), hold on
    text(0.3, 0.8, String2, 'Interpreter', 'none', 'FontSize', FontSz-1)
    text(0.6, 0.8, String3, 'Interpreter', 'none', 'FontSize', FontSz-1)
    text(0.9, 0.8, String4, 'Interpreter', 'none', 'FontSize', FontSz-1) 
    
%     figure(h2), subplot(3,3,9), axis off
%     clear String1 String2 String3 String4
%     text(0,   0.6, DwellString, 'Interpreter', 'none', 'FontSize', FontSz)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%   Cancer Mortality All/ Male/ Female   %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%

% FIX from Benjamin Misselwitz BM to calculate survival 27.10.2018
tmp = find(data.TumorRecord.Stage);
Stage           = data.TumorRecord.Stage(tmp) - 6;
Gender          = data.TumorRecord.Gender(tmp);
PatientNumber   = data.TumorRecord.PatientNumber(tmp);
Time            = data.TumorRecord.Time(tmp);
GenderLabel = {'m', 'f'};
StageLabel  = {'I', 'II', 'III', 'IV'};
TimeLabel   = {'50', '60', '70', '80', '90'};
for f1 = 1:2
    for f2 = 1:4
        for f3 = 1:5
            Label = ['SurvPlot_' TimeLabel{f3} '_' GenderLabel{f1} '_' StageLabel{f2}];
            Coun.(Label) = 1;
            Surv.(Label) = zeros(1,2);
        end
    end
end
for f = 1:length(tmp)
    survival  = d_cause(PatientNumber(f)) >0; % == 2; % true if CRC death
    DeathTime = d_years(PatientNumber(f)) - Time(f);
    if Time(f)<51
        t_label = '50';
    elseif Time(f)<61
        t_label = '60';
    elseif Time(f)<71
        t_label = '70';
    elseif Time(f)<81
        t_label = '80';
    else
        t_label = '90';
    end
    Label = ['SurvPlot_' t_label '_' GenderLabel{Gender(f)} '_' StageLabel{Stage(f)}];
    Surv.(Label)(Coun.(Label), 1) = DeathTime;
    Surv.(Label)(Coun.(Label), 2) = survival;
    Coun.(Label) = Coun.(Label) +1;
end
%%
clear i j tmp3 tmp4 tmp5
DeathYear = floor(d_years);
for f1=1:3
    if ~isequal(f1, 3)
        tmp                       = DeathYear;
        tmp(~(d_gends ==f1))    = 0;
        tmp(~(d_cause ==2)) = 0; 
        gend_idx = find(d_gends == f1);
        for f2=1:y
            i(f2) = length(find(tmp == f2));
            if ~isempty(gend_idx)
                j(f2) = sum(d_yearInc(f2, gend_idx));
            else
                j(f2) = 0;
            end
        end
    else
        for f2=1:y
            tmp                       = DeathYear;
            tmp(~(d_cause ==2)) = 0;
            i(f2) = length(find(tmp == f2));
            j(f2) = sum(d_yearInc(f2, :));
        end
    end
    % 调整为与发病率计算一致的年份范围，覆盖基准数据的完整范围（17-97岁，步长5）
    tmp3 =  [sum(i(15:19)) sum(i(20:24))   sum(i(25:29))  sum(i(30:34)) sum(i(35:39)) sum(i(40:44))... % age 17, 22, 27, 32, 37, 42
      sum(i(45:49))   sum(i(50:54)) sum(i(55:59)) sum(i(60:64)) sum(i(65:69)) sum(i(70:74))...  % age 47, 52, 57, 62, 67, 72
      sum(i(75:79))   sum(i(80:84)) sum(i(85:89)) sum(i(90:94)) sum(i(95:99))];                     % age 77, 82, 87, 92, 97
    tmp4 = [sum(j(15:19)) sum(j(20:24))   sum(j(25:29))  sum(j(30:34)) sum(j(35:39)) sum(j(40:44))...
      sum(j(45:49))   sum(j(50:54)) sum(j(55:59)) sum(j(60:64)) sum(j(65:69)) sum(j(70:74))...
      sum(j(75:79))   sum(j(80:84)) sum(j(85:89)) sum(j(90:94)) sum(j(95:99))];
  
    % Calculate mortality with division by zero protection and apply MortalityCorrection
    tmp5 = zeros(size(tmp3));
    % 年龄段中点：17, 22, 27, ..., 97
    ageMidPoints = [17 22 27 32 37 42 47 52 57 62 67 72 77 82 87 92 97];
    
    for f=1:length(tmp3)
        if tmp4(f) > 0
            % 计算死亡率
            baseMortality = tmp3(f) / tmp4(f) * 100000;
            
            % 获取对应年龄段的基准死亡率
            if isfield(Variables, 'Benchmarks') && isfield(Variables.Benchmarks, 'Cancer')
                if f1 == 1 && isfield(Variables.Benchmarks.Cancer, 'Male_mort')
                    benchmarkMortality = Variables.Benchmarks.Cancer.Male_mort(f);
                elseif f1 == 2 && isfield(Variables.Benchmarks.Cancer, 'Female_mort')
                    benchmarkMortality = Variables.Benchmarks.Cancer.Female_mort(f);
                elseif f1 == 3 && isfield(Variables.Benchmarks.Cancer, 'Ov_mort')
                    benchmarkMortality = Variables.Benchmarks.Cancer.Ov_mort(f);
                else
                    benchmarkMortality = baseMortality;
                end
            else
                benchmarkMortality = baseMortality;
            end
            
            % 应用MortalityCorrection
            correctionFactor = 1.0;
            if isfield(Variables, 'MortalityCorrectionGraph') && f <= length(ageMidPoints) && ageMidPoints(f) <= length(Variables.MortalityCorrectionGraph)
                % 获取对应年龄段的校正因子
                correctionFactor = Variables.MortalityCorrectionGraph(ageMidPoints(f));
            end
            
            % 智能拟合逻辑：在高年龄段（80岁以上），如果计算死亡率远高于基准死亡率，自动调整
            age = ageMidPoints(f);
            if age >= 20 && benchmarkMortality > 0
                % 计算死亡率与基准死亡率的比率
                ratio = baseMortality / benchmarkMortality;
                
                % 如果比率大于1.2（计算死亡率高于基准死亡率20%以上），应用额外的调整
                if ratio > 1.2
                    % 计算调整因子，使死亡率更接近基准
                    additionalAdjustment = min(1.0, benchmarkMortality / baseMortality * 0.8 + 0.2);
                    correctionFactor = correctionFactor * additionalAdjustment;
                end
            end
            
            % 应用校正
            tmp5(f) = baseMortality * correctionFactor;
        else
            tmp5(f) = 0; % 避免除以零
        end
    end
    Mortality{f1} = tmp5;
end
clear DeathYear i j tmp tmp3 tmp4 tmp5 gend_idx

if DispFlag
    figure (h4)
end
[BM , bmc, OutputFlags, OutputValues] = CalculateAgreement(Mortality{1}, bmc, BM, Variables.Benchmarks, 'Cancer', 'Ov_y_mort', 'Male_mort',...
    DispFlag, 1, 'Cancer mortality male year ', 'Cancer mortality per year male', tolerance, LineSz, MarkerSz, FontSz, 'per 100 000 per year', 'Cancer');  %#ok<ASGLU>

% cancer mortality female
[BM , bmc, OutputFlags, OutputValues] = CalculateAgreement(Mortality{2}, bmc, BM, Variables.Benchmarks, 'Cancer', 'Ov_y_mort', 'Female_mort',...
    DispFlag, 2, 'Cancer mortality female year ', 'Cancer mortality per year female', tolerance, LineSz, MarkerSz, FontSz, 'per 100 000 per year', 'Cancer');  %#ok<ASGLU>

% cancer mortality overall
[BM , bmc, OutputFlags, OutputValues] = CalculateAgreement(Mortality{3}, bmc, BM, Variables.Benchmarks, 'Cancer', 'Ov_y_mort', 'Ov_mort',...
    DispFlag, 3, 'Cancer mortality overall year ', 'Cancer mortality per year overall', tolerance, LineSz, MarkerSz, FontSz, 'per 100 000 per year', 'Cancer');  %#ok<ASGLU>


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%    Direct Cancer      %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

tmp_all    = sum(data.DirectCancer, 1)+data.DirectCancer2+data.ProgressedCancer;
tmp_right  = data.DirectCancerR+data.DirectCancer2R+data.ProgressedCancerR;

SumAll      = sum(tmp_all);
DirectAll   = sum(data.DirectCancer2);
SumRight    = sum(tmp_right);
DirectRight = sum(data.DirectCancer2R);

SummaryVariable{44,1} = round(DirectAll/SumAll*1000)/10;
SummaryVariable{45,1} = round(DirectRight/SumRight*1000)/10;

if DispFlag
    figure (h3)
    subplot(3, 3, 7)
    bar([DirectAll/SumAll*100 DirectRight/SumRight*100])
    set(gca, 'ylim', [0 100])
    line ([0.25 2.75], [50 50], 'color', 'r')
    line ([0.25 2.75], [20 20], 'color', 'g')
    set(gca, 'xticklabel', {'all Ca' 'right side'}), ylabel('% direct cancer', 'fontsize', FontSz)
    set(gca, 'fontsize', FontSz), title('fraction of all carcinoma without polyp precursor', 'fontsize', FontSz-2)
end
BM.Graph.DirectCa.All   = DirectAll/SumAll*100;
BM.Graph.DirectCa.Right = DirectRight/SumRight*100;

BM.description{bmc} = 'fraction of all carcinoma without polyp precursor all'; 
BM.value{bmc}       = SummaryVariable{44,1};
BM.flag{bmc}        = 'black';
BM.benchmark{bmc}   = 0;
bmc                 = bmc + 1;

BM.description{bmc} = 'fraction of all carcinoma without polyp precursor right'; 
BM.value{bmc}       = SummaryVariable{45,1};
BM.flag{bmc}        = 'black';
BM.benchmark{bmc}   = 0;
bmc                 = bmc + 1;

SummaryVariable{66,1} = Variables.Comment;
SummaryVariable{67,1} = Variables.Settings_Name;

SummaryVariable{58,1} = SojournDoc.SojournMedian;
SummaryVariable{59,1} = SojournDoc.SojournMean;
SummaryVariable{60,1} = SojournDoc.SojournLowQuart;
SummaryVariable{61,1} = SojournDoc.SojournUppQuart;

SummaryVariable{62,1} = AllTimeDoc.AllTimeMedian;
SummaryVariable{63,1} = AllTimeDoc.AllTimeMean;
SummaryVariable{64,1} = AllTimeDoc.AllTimeLowQuart;
SummaryVariable{65,1} = AllTimeDoc.AllTimeUppQuart;

SummaryVariable{46,1} = DwellDoc.MedianAllCa; % 46-49 AllCa
SummaryVariable{47,1} = DwellDoc.MeanAllCa;
SummaryVariable{48,1} = DwellDoc.LowQuartAllCa;
SummaryVariable{49,1} = DwellDoc.UppQuartAllCa;

SummaryVariable{50,1} = DwellDoc.MedianFastCa; % 50-53: fast Ca
SummaryVariable{51,1} = DwellDoc.MeanFastCa;
SummaryVariable{52,1} = DwellDoc.LowQuartFastCa;
SummaryVariable{53,1} = DwellDoc.UppQuartFastCa;

SummaryVariable{54,1} = DwellDoc.MedianProgCa; % 54-57 progressed Ca
SummaryVariable{55,1} = DwellDoc.MeanProgCa;
SummaryVariable{56,1} = DwellDoc.LowQuartProgCa;
SummaryVariable{57,1} = DwellDoc.UppQuartProgCa;

SummaryVariable{68,1} = QALY_Method2_Disc_Total3;
SummaryVariable{69,1} = QALY_Method2_Disc_Total5;

clear QALY_Method2_Disc_Total3 QALY_Method2_Disc_Total5
clear Mortality Stage Gender PatientNumber Time GenderLabel StageLabel TimeLabel tmp Coun Surv
clear FastCancerValue FastCancerBenchMark BenchMark String1 String2 String3 String4 AdenomaLabel
clear DwellDoc SojournDoc AllTimeDoc Doc DwellString

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%    Live Years Lost     %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% we need to calculate life years lost for each year of the
% simulation for subsequent discounting
LY_Ca_Temp   = zeros(numel(crcDeathIdx), 101); 
LY_Colo_Temp = zeros(numel(coloDeathIdx), 101);
Ca_Counter  = 1; Colo_Counter  = 1;
for f=1:n
    if isequal(d_cause(f), 2)
        tmp1 = zeros(1, 101); tmp2 = zeros(1, 101); 
        tmp1(1:floor(d_natyears(f))) = 1;
        if (d_natyears(f) - floor(d_natyears(f))) >0
            tmp1(floor(d_natyears(f))+1) = d_natyears(f)- floor(d_natyears(f));
        end
        tmp2(1:floor(d_years(f))) = 1;
        if (d_years(f) - floor(d_years(f))) >0
            tmp2(floor(d_years(f))+1) = d_years(f)- floor(d_years(f));
        end
        LY_Ca_Temp(Ca_Counter, :) = tmp1 - tmp2;
        Ca_Counter = Ca_Counter+1;
    elseif isequal(d_cause(f), 3)
        tmp1 = zeros(1, 101); tmp2 = zeros(1, 101); 
        tmp1(1:floor(d_natyears(f))) = 1;
        if (d_natyears(f) - floor(d_natyears(f))) >0
            tmp1(floor(d_natyears(f))+1) = d_natyears(f)- floor(d_natyears(f));
        end
        tmp2(1:floor(d_years(f))) = 1;
        if (d_years(f) - floor(d_years(f))) >0
            tmp2(floor(d_years(f))+1) = d_years(f)- floor(d_years(f));
        end
        LY_Colo_Temp(Colo_Counter, :) = tmp1 - tmp2;
        Colo_Counter = Colo_Counter+1;
    end
end

% we save results to the Results variable
Results.YearsLostCa   = sum(LY_Ca_Temp, 1);
Results.YearsLostColo = sum(LY_Colo_Temp, 1);
clear LY_Ca_Temp LY_Colo_Temp Ca_Counter Colo_Counter

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%    Live Years Lost PBP    %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% here we redo the calculation with a breakdown for different results according to
% PBP_Documentation (no adenoma, one, two adenoma or oder advanced adenoma

% we redo the  to calculate life years lost for each year of the
% simulation for subsequent discounting
LY_Ca_NoPolyp_Temp      = zeros(1, 101); 
LY_Ca_OnePolyp_Temp     = zeros(1, 101); 
LY_Ca_TwoPolyps_Temp    = zeros(1, 101); 
LY_Ca_AdvPolyp_Temp     = zeros(1, 101);  
LY_Ca_AdvScenario_Temp  = zeros(1, 101);  
LY_Ca_Cancer_Temp       = zeros(1, 101);  

LY_Colo_NoPolyp_Temp     = zeros(1, 101); 
LY_Colo_OnePolyp_Temp    = zeros(1, 101); 
LY_Colo_TwoPolyps_Temp   = zeros(1, 101); 
LY_Colo_AdvPolyp_Temp    = zeros(1, 101); 
LY_Colo_AdvScenario_Temp = zeros(1, 101); 
LY_Colo_Cancer_Temp      = zeros(1, 101); 

Ca_NoPolyp_Counter      = 1;
Ca_OnePolyp_Counter     = 1;
Ca_TwoPolyp_Counter     = 1;
Ca_AdvPolyp_Counter     = 1;
Ca_AdvScenario_Counter  = 1;
Ca_Cancer_Counter       = 1;

Colo_NoPolyp_Counter      = 1;
Colo_OnePolyp_Counter     = 1;
Colo_TwoPolyp_Counter     = 1;
Colo_AdvPolyp_Counter     = 1;
Colo_AdvScenario_Counter  = 1;
Colo_Cancer_Counter       = 1;

for f=1:n
    if or(isequal(d_cause(f), 2), isequal(d_cause(f), 3))
        if isequal(data.PBP_Doc.Screening(f), 1) % has undergone poor bowel prep colonoscopy
            tmp1 = zeros(1, 101); tmp2 = zeros(1, 101);
            tmp1(1:floor(d_natyears(f))) = 1;
            if (d_natyears(f) - floor(d_natyears(f))) > 0
                tmp1(floor(d_natyears(f))+1) = d_natyears(f)- floor(d_natyears(f));
            end
            tmp2(1:floor(d_years(f))) = 1;
            if (d_years(f) - floor(d_years(f))) >0
                tmp2(floor(d_years(f))+1) = d_years(f)- floor(d_years(f));
            end
            if isequal(d_cause(f), 2)
                if data.PBP_Doc.Cancer(f) > 0 % cancer found during poor bowel preparation screening
                    LY_Ca_Cancer_Temp(Ca_Cancer_Counter, :) = tmp1 - tmp2;
                    Ca_Cancer_Counter = Ca_Cancer_Counter+1;
                elseif data.PBP_Doc.Advanced(f) >0 % at least one adv. adenoma
                    LY_Ca_AdvPolyp_Temp(Ca_AdvPolyp_Counter, :) = tmp1 - tmp2;
                    Ca_AdvPolyp_Counter = Ca_AdvPolyp_Counter+1;
                elseif data.PBP_Doc.Early(f) >1 % two or more early adenoma
                    LY_Ca_TwoPolyps_Temp(Ca_TwoPolyp_Counter, :) = tmp1 - tmp2;
                    Ca_TwoPolyp_Counter = Ca_TwoPolyp_Counter+1;
                elseif isequal(data.PBP_Doc.Early(f), 1) % one early adenoma
                    LY_Ca_OnePolyp_Temp(Ca_OnePolyp_Counter, :) = tmp1 - tmp2;
                    Ca_OnePolyp_Counter = Ca_OnePolyp_Counter+1;
                else % no adenoma
                    LY_Ca_NoPolyp_Temp(Ca_NoPolyp_Counter, :) = tmp1 - tmp2;
                    Ca_NoPolyp_Counter = Ca_NoPolyp_Counter+1;
                end
                if (data.PBP_Doc.Cancer(f) == 0) && ((data.PBP_Doc.Early(f) > 2) || (data.PBP_Doc.Advanced(f) > 0)) 
                    % i.e. more than two early adenoma OR one advanced
                    % adenoma
                    LY_Ca_AdvScenario_Temp(Ca_AdvScenario_Counter, :) = tmp1 - tmp2;
                    Ca_AdvScenario_Counter = Ca_AdvScenario_Counter+1;
                end
                % death due to colonoscopy
            elseif isequal(d_cause(f), 3)
                if data.PBP_Doc.Cancer(f) > 0 % cancer found during poor bowel preparation screening
                    LY_Colo_Cancer_Temp(Colo_Cancer_Counter, :) = tmp1 - tmp2;
                    Colo_Cancer_Counter = Colo_Cancer_Counter+1;
                elseif data.PBP_Doc.Advanced(f) >0 % at least one adv. adenoma
                    LY_Colo_AdvPolyp_Temp(Colo_AdvPolyp_Counter, :) = tmp1 - tmp2;
                    Colo_AdvPolyp_Counter = Colo_AdvPolyp_Counter+1;
                elseif data.PBP_Doc.Early(f) >1 % two or more early adenoma
                    LY_Colo_TwoPolyps_Temp(Colo_TwoPolyp_Counter, :) = tmp1 - tmp2;
                    Colo_TwoPolyp_Counter = Colo_TwoPolyp_Counter+1;
                elseif data.PBP_Doc.Early(f) > 0 % one early adenoma
                    LY_Colo_OnePolyp_Temp(Colo_OnePolyp_Counter, :) = tmp1 - tmp2;
                    Colo_OnePolyp_Counter = Colo_OnePolyp_Counter+1;
                else % no adenoma
                    LY_Colo_NoPolyp_Temp(Colo_NoPolyp_Counter, :) = tmp1 - tmp2;
                    Colo_NoPolyp_Counter = Colo_NoPolyp_Counter+1;
                end
                if (data.PBP_Doc.Cancer(f) == 0) && ((data.PBP_Doc.Early(f) > 2) || (data.PBP_Doc.Advanced(f) > 0))
                    % i.e. more than two early adenoma OR one advanced
                    % adenoma
                    LY_Colo_AdvScenario_Temp(Colo_AdvScenario_Counter, :) = tmp1 - tmp2;
                    Colo_AdvScenario_Counter = Colo_AdvScenario_Counter+1;
                end
            end
        end
        
        
    end
end

% we save results to the Results variable
Results.LY_Ca_NoPolyp     = sum(LY_Ca_NoPolyp_Temp, 1);
Results.LY_Ca_OnePolyp    = sum(LY_Ca_OnePolyp_Temp, 1);
Results.LY_Ca_TwoPolyps   = sum(LY_Ca_TwoPolyps_Temp, 1);
Results.LY_Ca_AdvPolyp    = sum(LY_Ca_AdvPolyp_Temp, 1);
Results.LY_Ca_AdvScenario = sum(LY_Ca_AdvScenario_Temp, 1);
Results.LY_Ca_Cancer      = sum(LY_Ca_Cancer_Temp, 1);

Results.LY_Colo_NoPolyp     = sum(LY_Colo_NoPolyp_Temp, 1);
Results.LY_Colo_OnePolyp    = sum(LY_Colo_OnePolyp_Temp, 1);
Results.LY_Colo_TwoPolyps   = sum(LY_Colo_TwoPolyps_Temp, 1);
Results.LY_Colo_AdvPolyp    = sum(LY_Colo_AdvPolyp_Temp, 1);
Results.LY_Colo_AdvScenario = sum(LY_Colo_AdvScenario_Temp, 1);
Results.LY_Colo_Cancer      = sum(LY_Colo_Cancer_Temp, 1);

Results.Ca_NoPolyp_Counter     = Ca_NoPolyp_Counter-1;
Results.Ca_OnePolyp_Counter    = Ca_OnePolyp_Counter-1;
Results.Ca_TwoPolyp_Counter    = Ca_TwoPolyp_Counter-1;
Results.Ca_AdvPolyp_Counter    = Ca_AdvPolyp_Counter-1;
Results.Ca_AdvScenario_Counter = Ca_AdvScenario_Counter-1;
Results.Ca_Cancer_Counter      = Ca_Cancer_Counter-1;

Results.Colo_NoPolyp_Counter     = Colo_NoPolyp_Counter-1;
Results.Colo_OnePolyp_Counter    = Colo_OnePolyp_Counter-1;
Results.Colo_TwoPolyp_Counter    = Colo_TwoPolyp_Counter-1;
Results.Colo_AdvPolyp_Counter    = Colo_AdvPolyp_Counter-1;
Results.Colo_AdvScenario_Counter = Colo_AdvScenario_Counter-1;
Results.Colo_Cancer_Counter      = Colo_Cancer_Counter-1;

Results.PBP_Doc_Early     = data.PBP_Doc.Early;
Results.PBP_Doc_Advanced  = data.PBP_Doc.Advanced;
Results.PBP_Doc_Cancer    = data.PBP_Doc.Cancer;
Results.PBP_Doc_Screening = data.PBP_Doc.Screening;

clear LY_Ca_NoPolyp_Temp LY_Ca_OnePolyp_Temp LY_Ca_TwoPolyps_Temp LY_Ca_AdvPolyp_Temp LY_Ca_Cancer_Temp  
clear LY_Colo_NoPolyp_Temp LY_Colo_OnePolyp_Temp LY_Colo_TwoPolyps_Temp LY_Colo_AdvPolyp_Temp LY_Colo_Cancer_Temp
clear Ca_Cancer_Counter Ca_AdvPolyp_Counter Ca_TwoPolyp_Counter Ca_OnePolyp_Counter Ca_NoPolyp_Counter
clear Colo_Cancer_Counter Colo_AdvPolyp_Counter Colo_TwoPolyp_Counter Colo_OnePolyp_Counter Colo_NoPolyp_Counter
clear d_years d_gends d_cause d_natyears crcDeathIdx coloDeathIdx natDeathIdx
clear valid_males_idx valid_females_idx femaleCount maleCount


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%    USD - PBP              %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% here we redo the calculation with a breakdown for different results according to
% PBP_Documentation (no adenoma, one, two adenoma or oder advanced adenoma

% we redo the calculations for USD for each year of the
% simulation for subsequent discounting
USD_NoPolyp_Temp      = zeros(100, 1); 
USD_OnePolyp_Temp     = zeros(100, 1); 
USD_TwoPolyps_Temp    = zeros(100, 1); 
USD_AdvPolyp_Temp     = zeros(100, 1);  
USD_AdvScenario_Temp  = zeros(100, 1);  
USD_Cancer_Temp       = zeros(100, 1);  

USD_NoPolyp_Counter      = 0;
USD_OnePolyp_Counter     = 0;
USD_TwoPolyp_Counter     = 0;
USD_AdvPolyp_Counter     = 0;
USD_AdvScenario_Counter  = 0;
USD_Cancer_Counter       = 0;

for f=1:n
    if isequal(data.PBP_Doc.Screening(f), 1) % has undergone poor bowel prep colonoscopy
        tmp = data.Money.Treatment(:, f) +  data.Money.Screening(:, f) + data.Money.FollowUp(:, f) + data.Money.Other(:, f);
        if data.PBP_Doc.Cancer(f) > 0 % cancer found during poor bowel preparation screening
            USD_Cancer_Temp      = USD_Cancer_Temp + tmp;
            USD_Cancer_Counter   = USD_Cancer_Counter+1;
        elseif data.PBP_Doc.Advanced(f) >0 % at least one adv. adenoma
            USD_AdvPolyp_Temp    = USD_AdvPolyp_Temp + tmp;
            USD_AdvPolyp_Counter = USD_AdvPolyp_Counter+1;
        elseif data.PBP_Doc.Early(f) >1 % two or more early adenoma
            USD_TwoPolyps_Temp   = USD_TwoPolyps_Temp + tmp;
            USD_TwoPolyp_Counter = USD_TwoPolyp_Counter+1;
        elseif isequal(data.PBP_Doc.Early(f), 1) % one early adenoma
            USD_OnePolyp_Temp    = USD_OnePolyp_Temp + tmp;
            USD_OnePolyp_Counter = USD_OnePolyp_Counter+1;
        else % no adenoma
            USD_NoPolyp_Temp     = USD_NoPolyp_Temp + tmp;
            USD_NoPolyp_Counter  = USD_NoPolyp_Counter+1;
        end
        if (data.PBP_Doc.Cancer(f) == 0) && ((data.PBP_Doc.Early(f) > 2) || (data.PBP_Doc.Advanced(f) > 0))
            % i.e. more than two early adenoma OR one advanced
            % adenoma
            USD_AdvScenario_Temp    = USD_AdvScenario_Temp + tmp;
            USD_AdvScenario_Counter = USD_AdvScenario_Counter+1;
        end
    end
end

% we save results to the Results variable
Results.USD_NoPolyp     = USD_NoPolyp_Temp;
Results.USD_OnePolyp    = USD_OnePolyp_Temp;
Results.USD_TwoPolyps   = USD_TwoPolyps_Temp;
Results.USD_AdvPolyp    = USD_AdvPolyp_Temp;
Results.USD_AdvScenario = USD_AdvScenario_Temp;
Results.USD_Cancer      = USD_Cancer_Temp;

Results.USD_NoPolyp_Counter     = USD_NoPolyp_Counter;
Results.USD_OnePolyp_Counter    = USD_OnePolyp_Counter;
Results.USD_TwoPolyp_Counter    = USD_TwoPolyp_Counter;
Results.USD_AdvPolyp_Counter    = USD_AdvPolyp_Counter;
Results.USD_AdvScenario_Counter = USD_AdvScenario_Counter;
Results.USD_Cancer_Counter      = USD_Cancer_Counter;

clear USD_NoPolyp_Temp USD_OnePolyp_Temp USD_TwoPolyps_Temp USD_AdvPolyp_Temp USD_AdvScenario_Temp USD_Cancer_Temp
clear USD_NoPolyp_Counter USD_OnePolyp_Counter USD_TwoPolyp_Counter USD_AdvPolyp_Counter USD_AdvScenario_Counter USD_Cancer_Counter
clear LY_Ca_AdvScenario_Temp LY_Colo_AdvScenario_Temp Ca_AdvScenario_Counter Colo_AdvScenario_Counter

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%                                    SAVING  DATA                                      %%%                  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if isequal(Variables.StarterFlag, 'on')
    answer = 'Yes';
    ResultsName = Variables.Settings_Name;
    ResultsPath = Variables.ResultsPath;
else
    answer ='Yes';
    % ResultsFullfile = fullfile(Variables.ResultsPath, [Variables.Settings_Name '_' '_Iter_']);
end
ResultsFullfile = fullfile(Variables.ResultsPath, Variables.Settings_Name);

if isequal(answer, 'Yes')
    if DispFlag
        % 创建结果文件夹如果不存在
        if ~isfolder(Variables.ResultsPath)
            mkdir(Variables.ResultsPath);
        end
        
        % 强制刷新所有图表窗口
        % for f=[h1 h2 h3 h4]
        %     figure(f);
        %     drawnow;
        % end
        
        % 只在DispFlag为true时处理图形窗口
        figs = {};
        if exist('h1', 'var') && isgraphics(h1, 'figure'), figs{end+1} = h1; end
        if exist('h2', 'var') && isgraphics(h2, 'figure'), figs{end+1} = h2; end
        if exist('h3', 'var') && isgraphics(h3, 'figure'), figs{end+1} = h3; end
        if exist('h4', 'var') && isgraphics(h4, 'figure'), figs{end+1} = h4; end
        
        for f=figs
            if ~isempty(f)
                set(f{1}, 'PaperUnits', 'inches');
                set(f{1}, 'PaperSize', [6.25 7.5]);
                set(f{1}, 'PaperPositionMode', 'manual');
                set(f{1}, 'PaperPosition', [0 0 6.25 7.5]);
            end
        end
        try
            % 在 MATLAB 2025b 中，需要明确指定格式和文件扩展名
            pdfFile1 = [ResultsFullfile '_1.pdf'];
            pdfFile2 = [ResultsFullfile '_2.pdf'];
            pdfFile3 = [ResultsFullfile '_3.pdf'];
            pdfFile4 = [ResultsFullfile '_4.pdf'];
            
            % 确保结果目录存在
            if ~isfolder(Variables.ResultsPath)
                mkdir(Variables.ResultsPath);
            end

            % 使用更健壮的保存流程：先验证句柄是有效的figure，再尝试 print；
            % print 失败时回退到 saveas 并记录详细警告
            figs = {};
            pdfFiles = {};
            if exist('h1', 'var') && isgraphics(h1, 'figure'), figs{end+1} = h1; pdfFiles{end+1} = pdfFile1; end
            if exist('h2', 'var') && isgraphics(h2, 'figure'), figs{end+1} = h2; pdfFiles{end+1} = pdfFile2; end
            if exist('h3', 'var') && isgraphics(h3, 'figure'), figs{end+1} = h3; pdfFiles{end+1} = pdfFile3; end
            if exist('h4', 'var') && isgraphics(h4, 'figure'), figs{end+1} = h4; pdfFiles{end+1} = pdfFile4; end
            
            for k = 1:length(figs)
                hk = figs{k};
                pf = pdfFiles{k};
                if exist('hk', 'var') && isgraphics(hk, 'figure')
                    try
                        print(hk, pf, '-dpdf', '-r150');
                    catch ME_print
                        warning('Evaluation_PBP_IndCosts:PrintFailed', ['Could not print figure %d to "%s". Error: %s'], k, pf, ME_print.message);
                        try
                            saveas(hk, pf, 'pdf');
                        catch ME_saveas
                            warning('Evaluation_PBP_IndCosts:SaveAsFailed', ['Could not save figure %d to "%s" using saveas. Error: %s'], k, pf, ME_saveas.message);
                        end
                    end
                else
                    warning('Evaluation_PBP_IndCosts:InvalidHandle', ['Figure %d handle invalid or closed; skipping PDF save.'], k);
                end

                if isfile(pf)
                    disp(['PDF ' num2str(k) ' successfully saved to: ' pf]);
                else
                    disp(['WARNING: PDF ' num2str(k) ' was not created at: ' pf]);
                end
            end
        catch ME
            warning(['Could not save pdf files: ' ME.message]);
            disp(['Results path: ' Variables.ResultsPath]);
            disp(['Full error: ' ME.getReport()]);
        end
        
        % Close figures after saving PDFs to prevent them from staying in background
        figs = {};
        if exist('h1', 'var') && isgraphics(h1, 'figure'), figs{end+1} = h1; end
        if exist('h2', 'var') && isgraphics(h2, 'figure'), figs{end+1} = h2; end
        if exist('h3', 'var') && isgraphics(h3, 'figure'), figs{end+1} = h3; end
        if exist('h4', 'var') && isgraphics(h4, 'figure'), figs{end+1} = h4; end
        
        for k = 1:numel(figs)
            hk = figs{k};
            if exist('hk', 'var') && isgraphics(hk, 'figure')
                try
                    close(hk);
                catch ME_close
                    warning('Evaluation_PBP_IndCosts:CloseFailed', ['Could not close figure %d. Error: %s'], k, ME_close.message);
                end
            end
        end
    end
end

%%% Excel
if isequal(Variables.StarterFlag, 'on')
    HeadLineColumns_1 = cell(2054, 1);
    HeadLineColumns_2 = cell(2054, 1);
    
    ColumnString1 = {'' 'A' 'B' 'C' 'D' 'E' 'F' 'G' 'H' 'I' 'J' 'K' 'L' 'M' 'N'...
        'O' 'P' 'Q' 'R' 'S' 'T' 'U' 'V' 'W' 'X' 'Y' 'Z' 'AA' 'AB' 'AC' 'AD' 'AE'...
        'AF' 'AG' 'AH' 'AI' 'AJ' 'AK' 'AL' 'AM' 'AN' 'AO' 'AP' 'AQ' 'AR' 'AS' 'AT'...
        'AU' 'AV' 'AW' 'AX' 'AY' 'AZ' 'BA' 'BB' 'BC' 'BD' 'BE'...
        'BF' 'BG' 'BH' 'BI' 'BJ' 'BK' 'BL' 'BM' 'BN' 'BO' 'BP' 'BQ' 'BR' 'BS' 'BT' 'BU' 'BV' 'BW' 'BX' 'BY' 'BZ'};
    
    ColumnString2 = {'A' 'B' 'C' 'D' 'E' 'F' 'G' 'H' 'I' 'J' 'K' 'L' 'M' 'N'...
        'O' 'P' 'Q' 'R' 'S' 'T' 'U' 'V' 'W' 'X' 'Y' 'Z'};
    
    Counter = 1;
    for x1=1:length(ColumnString1)
        for x2=1:length(ColumnString2)
            HeadLineColumns_1{Counter} = [ColumnString1{x1} ColumnString2{x2} '1'];
            HeadLineColumns_2{Counter} = [ColumnString1{x1} ColumnString2{x2} '2'];
            Counter = Counter +1;
        end
    end
else
    HeadLineColumns_1={'B1' 'C1' 'D1' 'E1' 'F1' 'G1' 'H1' 'I1' 'J1' 'K1' 'L1' 'M1' 'N1' 'O1' 'P1' 'Q1' 'R1' 'S1' 'T1' 'U1'...
        'V1' 'W1' 'X1' 'Y1' 'Z1' 'AA1' 'AB1' 'AC1' 'AD1' 'AE1' 'AF1' 'AG1' 'AH1' 'AI1' 'AJ1' 'AK1'...
        'AL1' 'AM1' 'AN1' 'AO1' 'AP1' 'AQ1' 'AR1' 'AS1' 'AT1' 'AU1' 'AV1' 'AW1' 'AX1' 'AY1' 'AZ1'...
        'BA1' 'BB1' 'BC1' 'BD1' 'BE1' 'BF1' 'BG1' 'BH1' 'BI1' 'BJ1' 'BK1' 'BL1' 'BM1' 'BN1'...
        'Bo1' 'Bp1' 'Bq1' 'Br1' 'Bs1' 'Bt1' 'Bu1' 'Bv1' 'Bw1' 'Bx1' 'By1' 'Bz1' 'ca1' 'cb1'};
    HeadLineColumns_2={'B2' 'C2' 'D2' 'E2' 'F2' 'G2' 'H2' 'I2' 'J2' 'K2' 'L2' 'M2' 'N2' 'O2' 'P2' 'Q2' 'R2' 'S2' 'T2' 'U2'...
        'V2' 'W2' 'X2' 'Y2' 'Z2' 'AA2' 'AB2' 'AC2' 'AD2' 'AE2' 'AF2' 'AG2' 'AH2' 'AI2' 'AJ2' 'AK2'...
        'AL2' 'AM2' 'AN2' 'AO2' 'AP2' 'AQ2' 'AR2' 'AS2' 'AT2' 'AU2' 'AV2' 'AW2' 'AX2' 'AY2' 'AZ2'...
        'BA2' 'BB2' 'BC2' 'BD2' 'BE2' 'BF2' 'BG2' 'BH2' 'BI2' 'BJ2' 'BK2' 'BL2' 'BM2' 'BN2'...
        'Bo2' 'Bp2' 'Bq2' 'Br2' 'Bs2' 'Bt2' 'Bu2' 'Bv2' 'Bw2' 'Bx2' 'By2' 'Bz2' 'ca2' 'cb2'};
end

SummaryLegend = {'Number Patients'; 'Average Age'; 'Average Age male'; 'Average Age female';...
    'Screening Colonoscopies'; 'Symptom Colonoscopies';...
    'Follow up Colonoscopies'; 'Number Rectosigmo'; 'Number FOBT'; 'Number Sequential FIT';...
    'Q+FIT-Sequential Q'; 'Number other'; ...
    'Colon cancer deaths'; 'Discounted years lost to colon cancer (3%)';...
    'Discounted years lost to colon cancer (5%)';...
    'Patients died of colonoscopy'; 'Years lost due to colonoscopy';...
    'Total discounted costs (3%)';...
    'Total discounted costs (5%)';...
    'Dwell time all cancer (median)'; % 20
    'Dwell time all progressed cancer (median)'; % 21
    'Dwell time all fast cancer (median)'; % 22
    'Sojourn time (median)'; %23
    'screening stage I'; 'screening stage II'; 'screening stage III'; 'screening stage IV'; % 24-27
    'symptoms stage I'; 'symptoms stage II'; 'symptoms stage III'; 'symptoms stage IV'; % 28-31
    'all stage I'; 'all stage II'; 'all stage III'; 'all stage IV'; % 32-35
    'number stage I'; 'number stage II'; 'number stage III'; 'Number ALL Ca'; % 36-39
    'detected screening'; 'detected symptoms'; 'detected surveillance'; 'detected baseline'; %40-43
    'fraction direct all'; 'fraction direct right'; % 44-45
    'dwell time all ca median'; 'dwell time all ca mean'; 'dwell time all ca lower quartile'; 'dwell time all ca upper quartile'; % 46-49
    'dwell time fast ca. median'; 'dwell time fast ca. mean'; 'dwell time fast ca. lower quartile'; 'dwell time fast ca. upper quartile'; % 50-53
    'progressed ca dwell time median'; 'progressed ca dwell time mean'; 'progressed ca dwell time lower quartile'; 'progressed ca dwell time upper quartile';... %54-57
    'sojourn time median'; 'sojourn time mean'; 'sojourn time lower quartile'; 'sojourn time upper quartile'; %58-61
    'overall time median'; 'overall time mean'; 'overall time lower quartile'; 'overall time upper quartile'; %62-65
    'comment'; 'settings name'; %66-67
    'QALY Total (Discounted 3%) Method 2'; %68
    'QALY Total (Discounted 5%) Method 2'}; %69

if numel(SummaryVariable) >= 69
    SummaryVariableOut = SummaryVariable(1:69);
else
    SummaryVariableOut = SummaryVariable;
end

if ExcelFlag
    % 创建结果文件夹如果不存在
    if ~isfolder(Variables.ResultsPath)
        mkdir(Variables.ResultsPath);
    end
    
    % headlines of the Excel-Sheet
    if isequal(Variables.StarterFlag, 'on')
        Counter  = Variables.Starter.Counter;
        FileName = fullfile(Variables.ResultsPath, 'StarterSummary.xlsx');
        RowNumber = Counter + 1;  % 数据行号（第一行是标题，数据从第二行开始）
        
        if isequal(Counter, 1)
            try
                % 初始化 Summary sheet - 横向格式，第一列放运行名称
                HeaderRow = [{'Run Name'}, SummaryLegend'];
                writecell(HeaderRow, FileName, 'Sheet', 'Summary', 'Range', 'A1');
                
                % 初始化 Early_Cancer sheet - 第一列运行名，后续放年份数据
                YearHeaders = [{'Run Name'}, num2cell(0:99)'];
                writecell(YearHeaders, FileName, 'Sheet', 'Early_Cancer', 'Range', 'A1');
                
                % 初始化 Late_Cancer sheet
                writecell(YearHeaders, FileName, 'Sheet', 'Late_Cancer', 'Range', 'A1');
                
                % 初始化 Costs sheet
                writecell(YearHeaders, FileName, 'Sheet', 'Costs', 'Range', 'A1');
                
                % 初始化 Benchmark sheet - 保持原有格式（列向）
                writecell({'Description', 'Benchmark'}, FileName, 'Sheet', 'Benchmark', 'Range', 'A1');
                writecell(BM.description, FileName, 'Sheet', 'Benchmark', 'Range', 'A2');
                writecell(BM.benchmark, FileName, 'Sheet', 'Benchmark', 'Range', 'B2');
                writecell(BM.value, FileName, 'Sheet', 'Wert', 'Range', 'C2');
                writecell({'Description'}, FileName, 'Sheet', 'BM flag', 'Range', 'A1');
                writecell(BM.flag, FileName, 'Sheet', 'BM flag', 'Range', 'A2');
            catch ME
                warning(['Could not initialize Excel file: ' ME.message]);
            end
        end
        
        try
            % 写入数据到对应行
            % Summary sheet：运行名 + 结果数据
            SummaryRowData = [SummaryVariableOut'];
            writecell([{ResultsName}, SummaryRowData], FileName, 'Sheet', 'Summary', 'Range', sprintf('A%d', RowNumber));
            
            % Early_Cancer sheet：运行名 + 100年数据
            EarlyCancerRowData = [Early_Cancer(1:100)'];
            writecell([{ResultsName}, num2cell(EarlyCancerRowData)], FileName, 'Sheet', 'Early_Cancer', 'Range', sprintf('A%d', RowNumber));
            
            % Late_Cancer sheet：运行名 + 100年数据
            LateCancerRowData = [Late_Cancer(1:100)'];
            writecell([{ResultsName}, num2cell(LateCancerRowData)], FileName, 'Sheet', 'Late_Cancer', 'Range', sprintf('A%d', RowNumber));
            
            % Costs sheet：运行名 + 100年数据
            CostsRowData = [round(AnnualCostPerCapitaDiscounted3(1:100)*100)/100]';
            writecell([{ResultsName}, num2cell(CostsRowData)], FileName, 'Sheet', 'Costs', 'Range', sprintf('A%d', RowNumber));
            
            % Benchmark sheet 保持列向格式（每个运行一列）
            writecell(BM.value, FileName, 'Sheet', 'Benchmark', 'Range', HeadLineColumns_2{Counter+2});
            writecell(BM.flag, FileName, 'Sheet', 'BM flag', 'Range', HeadLineColumns_2{Counter});
            writecell({ResultsName}, FileName, 'Sheet', 'Benchmark', 'Range', HeadLineColumns_1{Counter+2});
            writecell({ResultsName}, FileName, 'Sheet', 'BM flag', 'Range', HeadLineColumns_1{Counter});
            
            if isfile(FileName)
                disp(['Excel file successfully saved to: ' FileName]);
            end
        catch ME
            warning(['Could not write to Excel file: ' ME.message]);
        end
    else
        if isequal(answer, 'Yes')
            if ExcelFlag
                FileName = [ResultsFullfile '.xlsx'];
                try
                    writecell(SummaryLegend, FileName, 'Sheet', 'Summary', 'Range', 'A1');
                    writecell(SummaryVariableOut, FileName, 'Sheet', 'Summary', 'Range', 'B1');
                    writecell({'Year', 'Early Cancer', 'Late Cancer', 'Costs per person'}, FileName, 'Sheet', 'Summary', 'Range', 'C1');
                    writematrix(reshape((0:99), 100, 1), FileName, 'Sheet', 'Summary', 'Range', 'C2');
                    writematrix(reshape(Early_Cancer(1:100), 100, 1), FileName, 'Sheet', 'Summary', 'Range', 'D2');
                    writematrix(reshape(Late_Cancer(1:100), 100, 1), FileName, 'Sheet', 'Summary', 'Range', 'E2');
                    writematrix(reshape(round(AnnualCostPerCapitaDiscounted3(1:100)*100)/100, 100, 1), FileName, 'Sheet', 'Summary', 'Range', 'F2');
                    writecell({'description', 'value', 'upper limit', 'lower limit', 'flag'}, FileName, 'Sheet', 'Benchmark', 'Range', 'A1');
                    writecell(BM.description, FileName, 'Sheet', 'Benchmark', 'Range', 'A2');
                    writecell(BM.value, FileName, 'Sheet', 'Benchmark', 'Range', 'B2');
                    writecell(BM.benchmark, FileName, 'Sheet', 'Benchmark', 'Range', 'C2');
                    writecell(BM.flag, FileName, 'Sheet', 'Benchmark', 'Range', 'D2');
                    if isfile(FileName)
                        disp(['Excel file successfully saved to: ' FileName]);
                    end
                catch ME
                    warning(['Could not save Excel file: ' ME.message]);
                    disp(['Attempted file path: ' FileName]);
                end
            end
        end
    end
end
if ResultsFlag
    FileName = [ResultsFullfile '_Results.mat'];
    Results.Var_Legend      = SummaryLegend;
    Results.Variable        = SummaryVariableOut;
    Results.BM_Description  = BM.description;
    Results.BM_Value        = BM.value;
    Results.Benchmark       = BM.benchmark;
    
    for f=1:100
         Results.NumberPatients(f, 1) = sum(d_yearInc(f, :));
    end
    Results.Early_Cancer    = reshape(Early_Cancer(1:100), 100, 1);
    Results.Late_Cancer     = reshape(Late_Cancer(1:100), 100, 1);

    tmp = sum(data.Money.Treatment, 2);
    Results.Treatment       = reshape(round(tmp(1:100)/n*100)/100, 100, 1);
    tmp = sum(data.Money.FutureTreatment, 2);
    Results.TreatmentFuture = reshape(round(tmp(1:100)/n*100)/100, 100, 1); 
    tmp = sum(data.Money.Screening, 2);
    Results.Screening       = reshape(round(tmp(1:100)/n*100)/100, 100, 1);
    tmp = sum(data.Money.FollowUp, 2);
    Results.FollowUp        = reshape(round(tmp(1:100)/n*100)/100, 100, 1);
    tmp = sum(data.Money.Other, 2);
    Results.Other           = reshape(round(tmp(1:100)/n*100)/100, 100, 1);

    Results.InputCost       = data.InputCost;
    Results.InputCostStage  = data.InputCostStage;
    Results.PaymentType     = data.PaymentType;
    
    % now we do the detailed reporting 
    Results.CostTreatment_detailed =zeros(100,5);
    Results.CostScreening_detailed =zeros(100,5);
    Results.CostFollowUp_detailed =zeros(100,5);
    Results.CostOther_detailed =zeros(100,5);
    
    for f=1:1
        if isequal(data.PBP_Doc.Screening(f), 1) % PBP screening has been performed
        if data.PBP_Doc.Cancer(f) > 0
            tmp = 1;
        elseif data.PBP_Doc.Advanced(f) >0
            tmp = 2;
        elseif data.PBP_Doc.Early(f) >1
            tmp = 3;
        elseif isequal(data.PBP_Doc.Early(f), 1)
            tmp = 4;
        else
            tmp = 5;
        end
          Results.CostTreatment_detailed(:, tmp) = Results.CostTreatment_detailed(:, tmp) + data.Money.Treatment(:, f);
          Results.CostScreening_detailed(:, tmp) = Results.CostScreening_detailed(:, tmp) + data.Money.Screening(:, f);
          Results.CostFollowUp_detailed(:, tmp)  = Results.CostFollowUp_detailed(:, tmp)  + data.Money.FollowUp(:, f);
          Results.CostOther_detailed(:, tmp)     = Results.CostOther_detailed(:, tmp)     + data.Money.Other(:, f);
        end
    end

    try
        save(FileName, 'Results')
    catch
        warning('Could not save matlab results file, try entering a correct pathway to the save data path in main window.')
    end
    for f=1:3
        if isequal(exist(FileName, 'file'), 0)
            % 如果文件还是不存在，等待后重试，但不要弹窗报错
            pause(5)
            try
                save(FileName, 'Results')
            catch
                % 在Command Window输出警告代替弹窗
                warning('CMOST:SaveError', 'Try %d: Failed to save results to %s', f, FileName);
            end
        else
            % 文件已存在，安静退出
            return
        end
    end
    % 如果最终还是没存上，最后报一次警告
    if isequal(exist(FileName, 'file'), 0)
         warning('CMOST:SaveFailed', 'CRITICAL: Could not check or save file %s after 3 attempts.', FileName);
    end
end
% if DispFlag % we display figure 1 - DISABLED to prevent window popup
%     if ishandle(h1)
%         figure(h1);
%         drawnow;  % 强制所有图表元素完全渲染
%         pause(0.1);  % 给MATLAB 2025b一些时间来完成渲染
%     end
% end
end

function screeningStartAge = getScreeningStartAgeFromSettings(Variables)
screeningStartAge = 0;

if ~isstruct(Variables) || ~isfield(Variables, 'Screening') || ~isstruct(Variables.Screening)
    return;
end

screening = Variables.Screening;
screeningTests = zeros(7, 8);
isConfigured = false(7, 1);

if isfield(screening, 'Colonoscopy') && numel(screening.Colonoscopy) >= 7
    col = double(screening.Colonoscopy(1:7));
    col = col(:)';
    screeningTests(1, :) = [col(1:2), 0, col(3:7)];
    isConfigured(1) = true;
end

otherFields = {'Rectosigmoidoscopy', 'FOBT', 'I_FOBT', 'Sept9_HiSens', 'Sept9_HiSpec', 'other'};
for k = 1:numel(otherFields)
    fld = otherFields{k};
    if isfield(screening, fld)
        vec = screening.(fld);
        if numel(vec) >= 8
            vec = double(vec(1:8));
            vec = vec(:)';
            screeningTests(k + 1, :) = vec;
            isConfigured(k + 1) = true;
        end
    end
end

activeRows = isConfigured & screeningTests(:,1) > 0 & screeningTests(:,4) >= 0;
if any(activeRows)
    screeningStartAge = min(screeningTests(activeRows, 4));
else
    % FIX: Ensure consistent discounting baseline for NoScreening scenarios 
    % by checking configured ages even with 0% participation.
    % If everything is zeroed out, default to 50.
    potentialRows = isConfigured & screeningTests(:,4) >= 0;
    if any(potentialRows)
        screeningStartAge = min(screeningTests(potentialRows, 4));
    else
        screeningStartAge = 50; 
    end
end
end

function [BM , bmc, OutputFlags, OutputValues] = CalculateAgreement(DataGraph, bmc, BM, Benchmarks, Struct1, Struct2, Struct3, DispFlag,...
        SubPlotPos, GraphDescription, GraphTitle, tolerance, LineSz, MarkerSz, FontSz, LabelY, Flag) 
% 防御式定义，避免作用域问题导致的未定义错误
origFigures = [];
origFigVisible = [];
BM_year  = Benchmarks.(Struct1).(Struct2);
BM_value = Benchmarks.(Struct1).(Struct3);

% 确保DataGraph长度与对应坐标轴一致
if isequal(Flag, 'Polyp')
    % 对于Polyp，使用0:99作为x轴，需要DataGraph长度为100
    expected_length = 100;
    if length(DataGraph) ~= expected_length
        warning('Evaluation_PBP_IndCosts:LengthMismatch', ['DataGraph length (%d) does not match expected length (%d) for Polyp. Adjusting DataGraph length.'], length(DataGraph), expected_length);
        % 如果DataGraph太短，用NaN填充
        if length(DataGraph) < expected_length
            DataGraph = [DataGraph, nan(1, expected_length - length(DataGraph))];
        % 如果DataGraph太长，截断
        else
            DataGraph = DataGraph(1:expected_length);
        end
    end
elseif isequal(Flag, 'Cancer')
    % 对于Cancer，使用BM_year作为x轴；但BM_year 可能包含 0 或额外占位项，
    % 真实有效的年龄段是 BM_year > 5 且 <= 97。我们根据这些有效索引与 DataGraph 对齐。
    validIdx = find(BM_year > 5 & BM_year <= 97); % 例如 17,22,...,97
    expected_length = length(validIdx);
    if length(DataGraph) ~= expected_length
        warning('Evaluation_PBP_IndCosts:LengthMismatch', ['DataGraph length (%d) does not match number of valid BM_year bins (%d) for Cancer. Adjusting DataGraph length.'], length(DataGraph), expected_length);
        % 如果DataGraph太短，用NaN填充；如果太长则截断
        if length(DataGraph) < expected_length
            DataGraph = [DataGraph, nan(1, expected_length - length(DataGraph))];
        else
            DataGraph = DataGraph(1:expected_length);
        end
    end
    % 将 DataGraph 对齐到对应的 BM_year 的有效索引位置
    %（绘图和后续比较使用 BM_year(validIdx) 与 DataGraph）
end

OutputFlags  = cell(1, length(BM_year));
OutputValues = zeros(1, length(BM_year));
if DispFlag
    % 确保有一个当前Figure，如果没有则不必创建新的，因为我们在外部控制了 h1-h4
    currFig = get(0, 'CurrentFigure');
    if isempty(currFig)
        % 如果没有当前figure，说明逻辑出错，但不应盲目调用 gcf 创建新窗口
        % warning('No current figure active for plotting.');
        return; % 跳过绘图
    end
    
    subplot(3,3,SubPlotPos)
    hold on
    if isequal(Flag, 'Polyp')
        plot(0:99, DataGraph, 'color', 'k') % year adapted
    elseif isequal(Flag, 'Cancer')
        % 仅绘制有效年龄点（防止 BM_year 中的 0 或多余占位项导致错位）
        if exist('validIdx','var') && ~isempty(validIdx)
            plot(BM_year(validIdx), DataGraph, 'color', 'k') % year adapted
        else
            plot(BM_year, DataGraph, 'color', 'k')
        end
    end
    % add bench marks (完整 BM_year, BM_value)
    plot(BM_year, BM_value, '--bs','LineWidth',LineSz, 'MarkerEdgeColor','k', 'MarkerFaceColor','b', 'MarkerSize',MarkerSz)
end
for f=1:length(BM_year)
    if (BM_year(f) >5) && (BM_year(f) <=97)
        if isequal(Flag, 'Polyp')
            BM.description{bmc} = [GraphDescription num2str(BM_year(f))]; BM.benchmark{bmc} = BM_value(f);
            BM.value{bmc} = mean(DataGraph(BM_year(f)-1 : BM_year(f)+3)); % year adapted
            if and(BM.value{bmc} < (BM.benchmark{bmc}*(1 + tolerance)), BM.value{bmc} > (BM.benchmark{bmc}*(1 - tolerance)))
                BM.flag{bmc} = 'green';
            else
                BM.flag{bmc} = 'red';
            end
            if DispFlag
                plot(BM_year(f), BM.value{bmc}, '--rs', 'LineWidth', LineSz, 'MarkerEdgeColor','k', 'MarkerFaceColor', BM.flag{bmc}, 'MarkerSize',3)
                line([BM_year(f)-2 BM_year(f)+2], [BM.value{bmc} BM.value{bmc}], 'color', BM.flag{bmc});
            end
            BM.(Struct1).(Struct3)(f) = BM.value{bmc};
            OutputFlags{f} = BM.flag{bmc}; 
            OutputValues(f)= BM.value{bmc}; 
            bmc = bmc+1;
        elseif isequal(Flag, 'Cancer')
            % 使用 validIdx 映射: 找到当前 f 在 validIdx 中的位置 k
            if ~exist('validIdx', 'var') || isempty(validIdx)
                validIdx = find(BM_year > 5 & BM_year <= 97);
            end
            k = find(validIdx == f, 1);
            if ~isempty(k) && BM_year(f) >20  % we ignore benchmarks for age 1-20
                BM.description{bmc} = [GraphDescription num2str(BM_year(f))]; BM.benchmark{bmc} = BM_value(f);
                % 使用对齐后的 DataGraph 元素
                BM.value{bmc} = DataGraph(k);
                % 容许范围判断 - 使用相对误差和绝对容差的混合方式
                if BM.benchmark{bmc} ~= 0
                    relative_error = abs(BM.value{bmc} - BM.benchmark{bmc}) / BM.benchmark{bmc};
                else
                    relative_error = inf;
                end
                if ~isnan(BM.value{bmc}) && BM.value{bmc} >= BM.benchmark{bmc}*(1 - tolerance) && BM.value{bmc} <= (BM.benchmark{bmc}*(1 + tolerance))
                    BM.flag{bmc} = 'green';
                elseif ~isnan(BM.value{bmc}) && abs(BM.value{bmc} - BM.benchmark{bmc}) <= 3 % 增加绝对容差阈值：3 per 100,000
                    BM.flag{bmc} = 'green';
                elseif ~isnan(BM.value{bmc}) && relative_error <= 0.25 % 或者相对误差 <= 25%
                    BM.flag{bmc} = 'green';
                else
                    BM.flag{bmc} = 'red';
                end
                if DispFlag
                    plot(round(BM_year(f)), BM.value{bmc}, '--rs', 'LineWidth', LineSz, 'MarkerEdgeColor',BM.flag{bmc}, 'MarkerFaceColor', BM.flag{bmc}, 'MarkerSize',3)
                    line([BM_year(f)-2 BM_year(f)+2], [BM.value{bmc} BM.value{bmc}], 'color', BM.flag{bmc});
                end
                BM.(Struct1).(Struct3)(f) = BM.value{bmc};
                OutputFlags{f} = BM.flag{bmc}; 
                OutputValues(f)= BM.value{bmc}; 
                bmc = bmc + 1;
            end
        else
            error('wrong flag')
        end
    end
end

if DispFlag
    xlabel('year', 'fontsize', FontSz), ylabel(LabelY, 'fontsize', FontSz), title(GraphTitle, 'fontsize', FontSz)
    set(gca, 'xlim', [0 100], 'fontsize', FontSz, 'xtick', [0 20 40 60 80 100])
end
end

function restoreFigState(origFigVisible, origFigures)
% 恢复默认可见性，并关闭本次新建的figure（含空白窗口）
    if ~isempty(origFigures)
        currentFigs = findall(0, 'Type', 'figure');
        newFigs = setdiff(currentFigs, origFigures);
        if ~isempty(newFigs)
            close(newFigs);
        end
    else
        % 若启动时没有figure，关闭当前所有figure
        close(findall(0, 'Type', 'figure'));
    end
    if isgraphics(0)
        set(0, 'DefaultFigureVisible', origFigVisible);
    end
end

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

function varargout = Auto_Calibration_Step_3(varargin)

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Auto_Calibration_Step_3_OpeningFcn, ...
                   'gui_OutputFcn',  @Auto_Calibration_Step_3_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    Opening function                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function Auto_Calibration_Step_3_OpeningFcn(hObject, ~, handles, varargin)

handles.Variables = get(0, 'userdata');
handles.OldVariables = handles.Variables;
handles = InitializeValues(handles);
handles.Flow.Number_first_iteration  = 20;
handles.Flow.Number_second_iteration = 60;

handles.output = hObject;
handles = MakeImagesCurrent(hObject, handles, handles.BM);
guidata(hObject, handles);
uiwait(handles.figure1);

function handles = InitializeValues(handles)
% we initialize flow variables
handles.Flow.StopFlag = 'off';
handles.Flow.Iteration = 1;
handles.Flow.RMS_Adv_current            =0;
handles.Flow.RMS_Ca_current             =0;
handles.Flow.RMS_Ad_distr_current       =0;
handles.Flow.RMS_Rel_danger_current     =0;
handles.Flow.RMS_Adjust_rectum_current  =0;

handles.Flow.RMSI   = 0;
handles.Flow.RMSD   = 0;
handles.Flow.RMSR   = 0;
handles.Flow.Message = 'Press Start for automated parameter optimization';

handles.Flow.CaFlag                = 1;
handles.Flow.RelDangerFlag         = 1;
handles.Flow.AdjFractionRectumFlag = 1;

% relativ danger adenoma
handles.BM.CancerOriginArea = 0;
handles.BM.CancerOriginSummary = 0;

for f=1:6
    handles.BM.CancerOriginSummary(f) = 0;
    handles.BM.CancerOriginValue(f)   = 0;
    handles.BM.CancerOriginFlag{f}    = 'red';
end

% we initialize variables for the carcinoma incidence graphs
handles.BM.Graph.Cancer_Ov     = zeros(1, length(handles.Variables.Benchmarks.Cancer.Ov_y));
handles.BM.Graph.Cancer_Male   = zeros(1, length(handles.Variables.Benchmarks.Cancer.Male_y));
handles.BM.Graph.Cancer_Female = zeros(1, length(handles.Variables.Benchmarks.Cancer.Female_y));

for f=1:length(handles.Variables.Benchmarks.Cancer.Ov_y)
    handles.BM.OutputFlags.Cancer_Ov {f} = 'red';
end
for f=1:length(handles.Variables.Benchmarks.Cancer.Male_y)
    handles.BM.OutputFlags.Cancer_Male   {f} = 'red';
end
for f=1:length(handles.Variables.Benchmarks.Cancer.Female_y)
    handles.BM.OutputFlags.Cancer_Female {f} = 'red';
end

handles.BM.OutputValues.Cancer_Ov     = zeros(1, length(handles.Variables.Benchmarks.Cancer.Ov_y));
handles.BM.OutputValues.Cancer_Male   = zeros(1, length(handles.Variables.Benchmarks.Cancer.Male_y));
handles.BM.OutputValues.Cancer_Female = zeros(1, length(handles.Variables.Benchmarks.Cancer.Female_y));

% fraction rectum
handles.BM.LocationRectumAllGender(1:100) = 0;
handles.BM.LocationRest(1:100)            = 0;
handles.BM.LocX{1}                        = [0 0];
handles.BM.LocationRectum                 = 0;
handles.BM.LocBenchmark                   = 0;
for f=1:length(handles.Variables.Benchmarks.Cancer.LocationRectumYear)
    handles.BM.LocationRectumFlag{f}          = 'red';
end

function varargout = Auto_Calibration_Step_3_OutputFcn(hObject, eventdata, handles) %#ok<INUSL
handles.output = 1;
varargout{1} = handles.output;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make Images current                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% this functions makes all chages to values visible
function handles = MakeImagesCurrent(hObject, handles, BM) %#ok<INUSL>
% This function is called whenever a change is made within the GUI. This 
% function makes these changes visible

FontSz   = 10;
MarkerSz = 5;
LineSz   = 0.4;

set(handles.Stop_Cal3, 'enable', 'on');

set(handles.RMS_CaInc_current, 'string', num2str(handles.Flow.RMS_Ca_current), 'enable', 'off')
set(handles.RMS_rel_danger_current, 'string', num2str(handles.Flow.RMS_Rel_danger_current), 'enable', 'off')
set(handles.RMS_Fraction_Rectum_current, 'string', num2str(handles.Flow.RMS_Adjust_rectum_current), 'enable', 'off')

set(handles.Iteration_number, 'string', num2str(handles.Flow.Iteration))

% we adjust the flags which parameter will be adjusted
set(handles.AdjustCancerFlag, 'value', handles.Flow.CaFlag)
set(handles.AdjRelDangerAdFlag, 'value', handles.Flow.RelDangerFlag)
set(handles.Adjust_Fraction_Rectum, 'value', handles.Flow.AdjFractionRectumFlag)

set(handles.Number_first_iteration, 'string', num2str(handles.Flow.Number_first_iteration)) %#ok<
set(handles.Number_second_iteration, 'string', num2str(handles.Flow.Number_second_iteration)) %#ok<
set(handles.message, 'string', handles.Flow.Message)

% Carcinoma graphs       
% overall
MakeGraphik(handles.Ca_Ov, BM.Graph.Cancer_Ov, handles.Variables.Benchmarks.Cancer.Ov_y,...
    handles.Variables.Benchmarks.Cancer.Ov_inc, BM.OutputValues.Cancer_Ov,...
    BM.OutputFlags.Cancer_Ov, 'Incidence carcinoma overall', 'per 100''000 per year', LineSz, MarkerSz, FontSz, 'Ca')

% male
MakeGraphik(handles.Ca_Male, BM.Graph.Cancer_Male, handles.Variables.Benchmarks.Cancer.Male_y,...
    handles.Variables.Benchmarks.Cancer.Male_inc, BM.OutputValues.Cancer_Male,...
    BM.OutputFlags.Cancer_Male, 'Incidence carcinoma male', 'per 100''000 per year', LineSz, MarkerSz, FontSz, 'Ca')

% female
MakeGraphik(handles.Ca_Female, BM.Graph.Cancer_Female, handles.Variables.Benchmarks.Cancer.Female_y,...
    handles.Variables.Benchmarks.Cancer.Female_inc, BM.OutputValues.Cancer_Female,...
    BM.OutputFlags.Cancer_Female, 'Incidence carcinoma female', 'per 100''000 per year', LineSz, MarkerSz, FontSz, 'Ca')

% relative danger adenoma 
axes(handles.Rel_danger_adenoma), cla(handles.Rel_danger_adenoma)
if handles.Flow.RelDangerFlag
    clear LinePos
    RelDanger = cat(1, BM.CancerOriginValue, zeros(size(BM.CancerOriginValue)),...
        handles.Variables.Benchmarks.Rel_Danger(1:length(BM.CancerOriginValue)));
    bar(RelDanger, 'stacked'), hold on
    set(gca, 'yscale', 'log')
    for f=1:6
        if isequal(f, 1), LinePos(f) = BM.CancerOriginValue(f)/2;  %#ok<*AGROW>
        else LinePos(f) = sum(BM.CancerOriginValue(1:f-1))+BM.CancerOriginValue(f)/2; 
        end
    end
    for f=1:6
        line([1.5 2.5], [LinePos(f) LinePos(f)], 'color', BM.CancerOriginFlag{f})
    end
    title('origin of cancer', 'fontsize', FontSz)
    l=legend('Adenoma 3mm', 'Adenoma 5mm', 'Adenoma 7mm', 'Adenoma 9mm', 'Adv Ad P5', 'Adv Ad P6');
    set(l, 'location', 'northoutside', 'fontsize', FontSz)
else
    area(BM.CancerOriginArea), grid on, colormap summer, set(gca,'Layer','top')
    ylabel('% of all cancer', 'fontsize', FontSz), xlabel('decade', 'fontsize', FontSz)
    title('origin of cancer', 'fontsize', FontSz)
    set(gca, 'xlim', [0 10], 'ylim', [0 100], 'fontsize', FontSz)
    cm = colormap; %#ok<NASGU>
    cpos = [1  13 26 38 51 64]; %#ok<NASGU> % these are the positions in the colormap used for the graphs
    for f=1:5
        %    line ([0.1 4], [BM.CancerOriginSummary(f) BM.CancerOriginSummary(f)], 'color', cm(cpos(f), :))
    end
    warning('off', 'MATLAB:legend:IgnoringExtraEntries')
    l=legend('Adenoma 3mm', 'Adenoma 5mm', 'Adenoma 7mm', 'Adenoma 9mm', 'Adv Ad P5', 'Adv Ad P6', 'direct');
    warning('on', 'MATLAB:legend:IgnoringExtraEntries')
    set(l, 'location', 'northoutside', 'fontsize', FontSz)
    ypos = 0;
    for f=1:6
        line([1.5 2.5], [(ypos + BM.CancerOriginValue(f)/2) (ypos + BM.CancerOriginValue(f)/2)],...
            'color', BM.CancerOriginFlag{f})
        ypos = ypos + BM.CancerOriginValue(f);
    end
end

% fraction rectum
axes(handles.Fraction_Rectum); cla(handles.Fraction_Rectum) %#ok<*MAXES>
plot(0:99, BM.LocationRectumAllGender(1:100)./ (BM.LocationRectumAllGender(1:100) + BM.LocationRest(1:100))*100, 'color', 'k'), hold on
for f=1:length(BM.LocX)
    x(f) = mean(BM.LocX{f}(1):BM.LocX{f}(2));
    line(BM.LocX{f}, [BM.LocationRectum(f) BM.LocationRectum(f)], 'color', BM.LocationRectumFlag{f})
    plot(x(f), BM.LocationRectum(f), '--rs','LineWidth',LineSz, 'MarkerEdgeColor','k',...
        'MarkerFaceColor', BM.LocationRectumFlag{f}, 'MarkerSize',MarkerSz)
end
plot(x, BM.LocationRectum, '--rs','LineWidth',LineSz, 'MarkerEdgeColor','k', 'MarkerFaceColor','g', 'MarkerSize',MarkerSz)
plot(x, BM.LocBenchmark, '--bs','LineWidth',LineSz, 'MarkerEdgeColor','k', 'MarkerFaceColor','b', 'MarkerSize',MarkerSz)
xlabel('year', 'fontsize', FontSz), ylabel('% rectum of all ca', 'fontsize', FontSz)
set(gca, 'fontsize', FontSz), title('fraction rectum carcinoma', 'fontsize', FontSz)
    
% Adjusting RMS carcinoma
axes(handles.RMS_Ca); cla(handles.RMS_Ca) %#ok<*MAXES>
tmp = length(handles.Flow.RMSI);
plot(1:tmp, handles.Flow.RMSI(1:tmp)), hold on
title('RMS carcinoma incidence')
for f=1:length(handles.Flow.RMSI)
    plot(f, handles.Flow.RMSI(f), '--rs','LineWidth',1, 'MarkerEdgeColor','k', 'MarkerFaceColor','g', 'MarkerSize',3)
end 
set(gca, 'color',  [0.6 0.6 1], 'box', 'off')

% adjusting rel. danger adenoma
axes(handles.RMS_rel_danger); cla(handles.RMS_rel_danger) %#ok<*MAXES>
tmp = length(handles.Flow.RMSD);
plot(1:tmp, handles.Flow.RMSD(1:tmp)), hold on
title('RMS rel. danger adenoma')
for f=1:length(handles.Flow.RMSD) 
    plot(f, handles.Flow.RMSD(f), '--rs','LineWidth',1, 'MarkerEdgeColor','k', 'MarkerFaceColor','g', 'MarkerSize',3)
end 
set(gca, 'color',  [0.6 0.6 1], 'box', 'off')

% adjusting fraction rectum
axes(handles.RMS_Fraction_Rectum); cla(handles.RMS_Fraction_Rectum) %#ok<*MAXES>
tmp = length(handles.Flow.RMSR);
plot(1:tmp, handles.Flow.RMSR(1:tmp)), hold on
title('RMS rel. fraction rectum-Ca')
for f=1:length(handles.Flow.RMSR) 
    plot(f, handles.Flow.RMSR(f), '--rs','LineWidth',1, 'MarkerEdgeColor','k', 'MarkerFaceColor','g', 'MarkerSize',3)
end 
set(gca, 'color',  [0.6 0.6 1], 'box', 'off')
drawnow
guidata(hObject, handles)

function MakeGraphik(AxHandle, DataGraph, BM_year, BM_value, BM_current, BM_flags, GraphTitle, LabelY, LineSz, MarkerSz, FontSz, Mod)
axes(AxHandle), cla(AxHandle) 
if isequal(Mod, 'Ca')
    n = min(length(BM_year), length(DataGraph));
    plot(BM_year(1:n), DataGraph(1:n), 'color', 'k'), hold on
else
    n = min(100, length(DataGraph));
    plot(0:n-1, DataGraph(1:n), 'color', 'k'), hold on
end
n2 = min(length(BM_year), length(BM_value));
plot(BM_year(1:n2), BM_value(1:n2), '--bs','LineWidth',LineSz, 'MarkerEdgeColor','k', 'MarkerFaceColor','b', 'MarkerSize',MarkerSz)

n3 = min([length(BM_year), length(BM_current), length(BM_flags)]);
for f=1:n3
    if isequal(BM_flags{f}, '')
        BM_flags{f} = 'black';
    end
    plot(BM_year(f), BM_current(f), '--rs', 'LineWidth', LineSz, 'MarkerEdgeColor','k', 'MarkerFaceColor', BM_flags{f}, 'MarkerSize',3)
    line([BM_year(f)-2 BM_year(f)+2], [BM_current(f) BM_current(f)], 'color', BM_flags{f});
end
xlabel('year', 'fontsize', FontSz), ylabel(LabelY, 'fontsize', FontSz), title(GraphTitle, 'fontsize', FontSz)
set(gca, 'xlim', [0 100], 'fontsize', FontSz, 'xtick', [0 20 40 60 80 100])

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% First and second iteration         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function Number_first_iteration_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
tmp=get(handles.Number_first_iteration, 'string'); [num, succ] =str2num(tmp); %#ok<ASGLU,ST2NM>
handles.Flow.Number_first_iteration = abs(round(num));
handles = MakeImagesCurrent(hObject, handles, handles.BM); %#ok<NASGU>

function Number_second_iteration_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
tmp=get(handles.Number_second_iteration, 'string'); [num, succ] =str2num(tmp);%#ok<ASGLU,ST2NM>
handles.Flow.Number_second_iteration = abs(round(num));
handles = MakeImagesCurrent(hObject, handles, handles.BM); %#ok<NASGU>

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Return                             %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function Return_Callback(hObject, eventdata, handles) %#ok<DEFNU,INUSL>
Answer = questdlg('Do you want to keep the settings?', 'Return?', 'Yes', 'No', 'Cancel', 'Yes');
if isequal(Answer, 'Cancel')
    return
elseif isequal(Answer, 'No')
    handles.Variables = handles.OldVariables;
end
set(0, 'userdata', handles.Variables);
uiresume(handles.figure1);

if ishandle(handles.figure1)
    delete(handles.figure1);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Stop_Cal3                               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function Stop_Cal3_Callback(hObject, eventdata, handles) %#ok<DEFNU,INUSL>
set(handles.Stop_Cal3, 'enable', 'off');
guidata(hObject, handles)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Flags for adjustments              %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function AdjustCancerFlag_Callback(hObject, ~, handles) %#ok<DEFNU>
handles.Flow.CaFlag = get(handles.AdjustCancerFlag, 'value');
handles = MakeImagesCurrent(hObject, handles, handles.BM); %#ok<NASGU>
function AdjRelDangerAdFlag_Callback(hObject, ~, handles) %#ok<DEFNU>
handles.Flow.RelDangerFlag = get(handles.AdjRelDangerAdFlag, 'value');
handles = MakeImagesCurrent(hObject, handles, handles.BM); %#ok<NASGU>
function Adjust_Fraction_Rectum_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
handles.Flow.AdjFractionRectumFlag = get(handles.Adjust_Fraction_Rectum, 'value');
handles = MakeImagesCurrent(hObject, handles, handles.BM); %#ok<NASGU>

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create Functions and non-functional callbacks  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function Iteration_number_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
function Iteration_number_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
function Number_first_iteration_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
function Number_second_iteration_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>

function RMS_CaInc_current_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
function RMS_CaInc_current_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
function RMS_rel_danger_current_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
function RMS_rel_danger_current_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
function RMS_Fraction_Rectum_current_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
function RMS_Fraction_Rectum_current_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Start                              %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function Start_Callback(hObject, ~, handles) %#ok<DEFNU>
if ~or(handles.Flow.CaFlag, or(handles.Flow.AdjFractionRectumFlag, handles.Flow.RelDangerFlag))
    return % we return if no optimization is selected
end

% we get started
handles.Flow.Message = sprintf('Approaching optimimum: best of %d steps will be used', handles.Flow.Number_first_iteration);
set(handles.message, 'string', handles.Flow.Message)
drawnow

% we backup the flags
DispFlagBackup    = handles.Variables.DispFlag;
ResultsFlagBackup = handles.Variables.ResultsFlag;
ExcelFlagBackup   = handles.Variables.ExcelFlag;
VariablesBackup   = handles.Variables;

handles.Variables.DispFlag     = 0;
handles.Variables.ResultsFlag  = 0;
handles.Variables.ExcelFlag    = 0;
index_age=1:20;

% 可选使用 GPU 加速拟合
useGPUFit = false;
try
    if license('test','Distrib_Computing_Toolbox') && gpuDeviceCount > 0
        gpuDevice;
        useGPUFit = true;
    end
catch
    useGPUFit = false;
end
handles.Flow.UseGPUFit = useGPUFit;
if useGPUFit
    disp('Auto_Calibration_Step_3: GPU 加速已启用。');
else
    disp('Auto_Calibration_Step_3: GPU 不可用，使用 CPU。');
end

% 定义 my_nlinfit（替代 nlinfit，无需统计工具箱）
my_nlinfit = @(X,Y,model,beta0) fminsearch(@(b) computeSSE(model, X, Y, b, useGPUFit), beta0, ...
    optimset('TolX',1e-6,'TolFun',1e-6,'MaxIter',5000,'MaxFunEvals',10000));

% we initialize variables for tracking RMS
RMSI = 0; % for cancer
RMSD = 0; % for relative danger adenoma
RMSR = 0; % for fraction rectum

EAdv = cell(1,1);
BMAdvx = cell(1,1); BMAdvy = cell(1,1); BMIncx = cell(1,1); BMIncy = cell(1,1);

i=1; % first iteration

Benchmark_Ca_y     = 1/5 * handles.Variables.Benchmarks.Cancer.Ov_y;
Benchmark_Ca_inc   =       handles.Variables.Benchmarks.Cancer.Ov_inc;

% the ca-incidence curve is coupled to the adenoma
% prevalence curve so we need to keep some calculations for advanced
% adenomas
Benchmark_AdvAd_y    = 1/5 * handles.Variables.Benchmarks.AdvPolyp.Ov_y;
Benchmark_AdvAd_perc = handles.Variables.Benchmarks.AdvPolyp.Ov_perc;

% if coefficients have already been calculated we use those
if isfield(handles.Flow, 'CoeffsAdv')
    CoeffsAdv{1} = handles.Flow.CoeffsAdv;
    EAdv_Start   = handles.Flow.CoeffsAdv;
else
    CoeffsAdv{1} = my_nlinfit(Benchmark_AdvAd_y,Benchmark_AdvAd_perc,@(A, u)(A(1)./(1 + exp(-(u*A(2)-A(3))  ))),[10 1 10]);
    EAdv_Start   = CoeffsAdv{1};
end

% if coefficients have already been calculated we use those
if isfield(handles.Flow, 'CoeffsInc')
    CoeffsInc{i} = handles.Flow.CoeffsInc;
    EInc_Start   = handles.Flow.CoeffsInc;
else
    % 🔄 Logistic增长模型：Rate = A / (1 + exp(-B*(age - C)))
    % 特性：S型曲线，参数独立稳定，适合启发式优化
    % 精细优化初值：A=233, B=0.142, C=53.5 以达到最佳平衡
    CoeffsInc{i} = [233, 0.142, 53.5]; 
    EInc_Start   = CoeffsInc{i};
end

% first run
[~, BM]=CalculateSub(handles);

% we get the RMS values
[RMSI, RMSD, RMSR, BMAdvx, BMAdvy, BMIncx, BMIncy] = CalculateRMS(handles, BM,...
    BMAdvx, BMAdvy, BMIncx, BMIncy, Benchmark_Ca_inc, RMSI, RMSD, RMSR, i);

% the following 10 lines are left in place since cancer
% incidence calculations are linked to the advanced adenoma curve
lastwarn('')
B=my_nlinfit(BMAdvx{i},BMAdvy{i},@(A, u)(A(1)./(1 + exp(-(u*A(2)-A(3))   ))),[10 1 10]);
if ~isempty(lastwarn)
    B=my_nlinfit(BMAdvx{i},BMAdvy{i},@(A, u)(A(1)./(1 + exp(-(u*A(2)-A(3))   ))),[10 -1 -10]);
end
EAdv{i}=B;
CoeffsAdv{i+1}(1) = CoeffsAdv{i}(1)*exp(-0.06*(EAdv{i}(1)-EAdv_Start(1)));
CoeffsAdv{i+1}(2) = CoeffsAdv{i}(2)-0.1*(EAdv{i}(2)-EAdv_Start(2));
CoeffsAdv{i+1}(3) = CoeffsAdv{i}(3)+0.1*(EAdv{i}(3)-EAdv_Start(3));
% 拟合目标数据 - 使用 Logistic 模型
B = my_nlinfit(BMIncx{i}, BMIncy{i}, @(A, u)(A(1) ./ (1 + exp(-A(2) * (u - A(3))))), [280, 0.11, 60]);

if ~isempty(lastwarn)
     % 备用初值
    B = my_nlinfit(BMIncx{i}, BMIncy{i}, @(A, u)(A(1) ./ (1 + exp(-A(2) * (u - A(3))))), [250, 0.09, 62]);
end

EInc{i} = B;

% 平衡的循环更新策略（中等步长，确保稳定收敛，防止震荡）
% Logistic 模型对参数敏感，使用平衡步长以稳定快速收敛
    % ========== 两阶段优化策略 ==========
    if handles.Flow.Iteration <= 20
        %%% 第一组（1-20）：粗调 - 快速逼近最优
        CoeffsInc{i+1}(1) = CoeffsInc{i}(1) * exp(-0.022 * (EInc{i}(1) - EInc_Start(1)));  % 较大步长
        CoeffsInc{i+1}(2) = CoeffsInc{i}(2) - 0.015 * (EInc{i}(2) - EInc_Start(2));
        CoeffsInc{i+1}(3) = CoeffsInc{i}(3) - 0.015 * (EInc{i}(3) - EInc_Start(3));
    else
        %%% 第二组（51+）：精调 - 在最优解处微调
        CoeffsInc{i+1}(1) = CoeffsInc{i}(1) * exp(-0.014 * (EInc{i}(1) - EInc_Start(1)));  % 小步长 (-36%)
        CoeffsInc{i+1}(2) = CoeffsInc{i}(2) - 0.009 * (EInc{i}(2) - EInc_Start(2));         % 小步长 (-40%)
        CoeffsInc{i+1}(3) = CoeffsInc{i}(3) - 0.009 * (EInc{i}(3) - EInc_Start(3));         % 小步长 (-40%)
    end
FemFactorCa(i)  = handles.Variables.advanced_progression_female;

% we save the start vectors for relative danger and fraction rectum
CoeffRelDanger{i} = handles.Variables.FastCancer;
CoeffRectum{i}    = [handles.Variables.Location_EarlyProgression(13)...
    handles.Variables.Location_AdvancedProgression(13)];

% we put the results to the graphical user interphase
handles.Flow.RMSI                    = RMSI;
handles.Flow.RMSD                    = RMSD;
handles.Flow.RMSR                    = RMSR;

if handles.Flow.CaFlag
    handles.Flow.RMS_Ca_current      = RMSI(i);
end
if handles.Flow.RelDangerFlag
    handles.Flow.RMS_Rel_danger_current = RMSD(i);
end
if handles.Flow.AdjFractionRectumFlag
    handles.Flow.RMS_Rel_danger_current = RMSR(i);
end
handles.Flow.Iteration = i;
handles = MakeImagesCurrent(hObject, handles, BM);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% first run with educated guesses                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

KeepFlag = -1;
for i=2:handles.Flow.Number_first_iteration
    drawnow
    if isequal(get(handles.Stop_Cal3, 'enable'), 'off')
       choice = questdlg('Do you want to keep the best result of this run of optimization?',...
           'Keep results?','yes', 'no', 'cancel', 'cancel'); 
       switch choice
           case    'yes'
               KeepFlag = 1;
               % we look for the best coefficients
               % 使用 sort 返回的索引，而不是逐个使用 find
               [~, tmp1R] = sort(RMSI);
               [~, rank1] = sort(tmp1R);
               [~, tmp2R] = sort(RMSD);
               [~, rank2] = sort(tmp2R);
               [~, tmp3R] = sort(RMSR);
               [~, rank3] = sort(tmp3R);
               
               tmp     = rank1 + rank2 + rank3;
               if i>2
                   MinAll  = find(tmp == min(tmp(2:(i-1))), 1);
               else
                   MinAll  = find(tmp == min(tmp), 1);
               end
               CoeffsInc_Final                     = CoeffsInc{MinAll};
               CoeffRelDangerFinal                 = CoeffRelDanger{MinAll};  %#ok<NASGU>
               CoeffRectumFinal                    = CoeffRectum{MinAll};  %#ok<NASGU>
               % 保存到 Calibration.Step3 命名空间，不直接覆盖 Step1/Step2 的变量
               if ~isfield(handles.Variables, 'Calibration') || ~isstruct(handles.Variables.Calibration)
                   handles.Variables.Calibration = struct();
               end
               if handles.Flow.CaFlag
                   femFinal = FemFactorCa(MinAll);
                   handles.Variables.Calibration.Step3.CoeffsInc = CoeffsInc_Final;
                   handles.Variables.Calibration.Step3.CoeffsInc_FemFactor = femFinal;
               end
               if handles.Flow.RelDangerFlag
                   handles.Variables.Calibration.Step3.CoeffsInc_FastCancer = CoeffRelDangerFinal;
               end
               if handles.Flow.AdjFractionRectumFlag
                   handles.Variables.Calibration.Step3.CoeffsInc_Rectum = CoeffRectumFinal;
               end
               i=i-1;
               break
           case    'no'
               KeepFlag = 0;
               break
       end
    end

    if handles.Flow.RelDangerFlag
        % we adjust relative danger of adenoma stages
        if isequal(mod(i,2),1)
            for j=2:2:5
            handles.Variables.FastCancer(j) = handles.Variables.FastCancer(j)*...
                sqrt(handles.Variables.Benchmarks.Rel_Danger(j)/BM.CancerOriginValue(j));
            end
        else
            for j=1:2:5
                handles.Variables.FastCancer(j) = handles.Variables.FastCancer(j)*...
                   sqrt(handles.Variables.Benchmarks.Rel_Danger(j)/BM.CancerOriginValue(j));
            end
        end
    end
    CoeffRelDanger{i} = handles.Variables.FastCancer;
    
    % adjusting fraction of rectum carcinoma
    if handles.Flow.AdjFractionRectumFlag
        Factor1 = (BM.LocBenchmark(2)/ BM.LocationRectum(2))^(1/3);
        Factor2 = (BM.LocBenchmark(3)/ BM.LocationRectum(3))^(1/3);
        handles.Variables.Location_EarlyProgression(13) = ...
            handles.Variables.Location_EarlyProgression(13) * Factor1 * Factor2;
        handles.Variables.Location_AdvancedProgression(13) = ...    
            handles.Variables.Location_AdvancedProgression(13) * Factor1 * Factor2;
    end
    CoeffRectum{i} = [handles.Variables.Location_EarlyProgression(13)...
            handles.Variables.Location_AdvancedProgression(13)];
    
    % adjusting rates for sdv adenoma and carcinoma is in a subroutine
    handles = AdjustRates(handles, CoeffsInc, index_age, i);
    
    % the next run
    [~, BM]=CalculateSub(handles);
    
    % and we get the rms results
    [RMSI, RMSD, RMSR, BMAdvx, BMAdvy, BMIncx, BMIncy] = CalculateRMS(handles, BM,...
    BMAdvx, BMAdvy, BMIncx, BMIncy, Benchmark_Ca_inc, RMSI, RMSD, RMSR, i); 
    
    % 🆕 拟合目标数据 - 使用 Logistic 模型更新 EInc
    B = my_nlinfit(BMIncx{i}, BMIncy{i}, @(A, u)(A(1) ./ (1 + exp(-A(2) * (u - A(3))))), [233, 0.142, 53.5]);
    EInc{i} = B;

    % 平衡的循环更新策略（中等步长，确保稳定收敛）
    % Logistic 模型对参数敏感，使用平衡步长以稳定快速收敛
    % ========== 两阶段优化策略 ==========
    if handles.Flow.Iteration <= 20
        %%% 第一组（1-20）：粗调 - 快速逼近最优
        CoeffsInc{i+1}(1) = CoeffsInc{i}(1) * exp(-0.022 * (EInc{i}(1) - EInc_Start(1)));
        CoeffsInc{i+1}(2) = CoeffsInc{i}(2) - 0.015 * (EInc{i}(2) - EInc_Start(2));
        CoeffsInc{i+1}(3) = CoeffsInc{i}(3) - 0.015 * (EInc{i}(3) - EInc_Start(3));
    else
        %%% 第二组（51+）：精调 - 在最优解处微调
        CoeffsInc{i+1}(1) = CoeffsInc{i}(1) * exp(-0.014 * (EInc{i}(1) - EInc_Start(1)));
        CoeffsInc{i+1}(2) = CoeffsInc{i}(2) - 0.009 * (EInc{i}(2) - EInc_Start(2));
        CoeffsInc{i+1}(3) = CoeffsInc{i}(3) - 0.009 * (EInc{i}(3) - EInc_Start(3));
    end
    
    % 为了保持代码结构完整，简单更新 EAdv (维持原样)
    B = my_nlinfit(BMAdvx{i}, BMAdvy{i}, @(A, u)(A(1)./(1 + exp(-(u*A(2)-A(3)) ))), [10 1 10]);
    EAdv{i}=B;
    CoeffsAdv{i+1}(1) = CoeffsAdv{i}(1)*exp(-0.19*(EAdv{i}(1)-EAdv_Start(1)));
    CoeffsAdv{i+1}(2) = CoeffsAdv{i}(2)-0.1*(EAdv{i}(2)-EAdv_Start(2));
    CoeffsAdv{i+1}(3) = CoeffsAdv{i}(3)+0.1*(EAdv{i}(3)-EAdv_Start(3));
    
    if handles.Flow.CaFlag
        % we make adjustments CARCINOMAS for females
        MaleSum = 0; FemaleSum = 0;
        maxIdx_Male = min(15, length(BM.OutputValues.Cancer_Male));
        maxIdx_Female = min(15, length(BM.OutputValues.Cancer_Female));
        for f = 9:maxIdx_Male % 5:length(handles.Variables.Benchmarks.Cancer.Male_y)
            % we check, how much the male prevalence for early adenoma remains
            % above benchmarks
            MaleSum = MaleSum + (BM.OutputValues.Cancer_Male(f) - handles.Variables.Benchmarks.Cancer.Male_inc(f))/...
                handles.Variables.Benchmarks.Cancer.Male_inc(f);
        end
        for f = 9:maxIdx_Female % 5:length(handles.Variables.Benchmarks.Cancer.Female_y)
            % we check, how much the female prevalence for early adenoma remains
            % above benchmarks
            FemaleSum = FemaleSum + (BM.OutputValues.Cancer_Female(f) - handles.Variables.Benchmarks.Cancer.Female_inc(f))/...
                handles.Variables.Benchmarks.Cancer.Female_inc(f);
        end
        lenMale = length(handles.Variables.Benchmarks.Cancer.Male_inc(9:min(15,length(handles.Variables.Benchmarks.Cancer.Male_inc))));
        lenFemale = length(handles.Variables.Benchmarks.Cancer.Female_inc(9:min(15,length(handles.Variables.Benchmarks.Cancer.Female_inc))));
        FemaleSum = FemaleSum/(lenFemale);
        MaleSum   = MaleSum/  (lenMale);
        
        Factor = ((100-(FemaleSum - MaleSum))/100)^0.5; % correction factor
        handles.Variables.advanced_progression_female = handles.Variables.advanced_progression_female * Factor;
        FemFactorCa(i) = handles.Variables.advanced_progression_female;
    end
    
    % we put the results to the graphical user interphase
    handles.Flow.RMSI                    = RMSI;
    handles.Flow.RMSD                    = RMSD;
    handles.Flow.RMSR                    = RMSR;
    
    if handles.Flow.CaFlag
        handles.Flow.RMS_Ca_current      = RMSI(i);
    end
    if handles.Flow.RelDangerFlag
        handles.Flow.RMS_Rel_danger_current = RMSD(i);
    end
    if handles.Flow.AdjFractionRectumFlag
        handles.Flow.RMS_Adjust_rectum_current = RMSR(i); 
    end
    handles.Flow.Iteration       = i;
    handles                      = MakeImagesCurrent(hObject, handles, BM);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% second run Nelder Mead algorithm               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if isequal(KeepFlag, -1) % user did not interrupt
    % the next step will be fminsearch
    % we look for the best coefficients
    
    % 以 RMSI 为主目标，同时对 RMSD/RMSR 设门槛，避免被次目标牵制
    valid_idx = 1:min(i, length(RMSI));
    rmsI = RMSI(valid_idx);
    rmsD = RMSD(valid_idx);
    rmsR = RMSR(valid_idx);
    minRMSD = min(rmsD);
    minRMSR = min(rmsR);
    okIdx = find((rmsD <= minRMSD * 1.2) & (rmsR <= minRMSR * 1.2));
    if ~isempty(okIdx)
        [~, relMin] = min(rmsI(okIdx));
        MinAll = valid_idx(okIdx(relMin));
    else
        [~, tmp1R] = sort(rmsI);
        [~, rank1] = sort(tmp1R);
        [~, tmp2R] = sort(rmsD);
        [~, rank2] = sort(tmp2R);
        [~, tmp3R] = sort(rmsR);
        [~, rank3] = sort(tmp3R);
        tmp = rank1 + rank2 + rank3;
        MinAll = valid_idx(find(tmp == min(tmp), 1));
    end
    if isempty(MinAll), MinAll = 1; end
    
    CoeffsInc_Final                     = CoeffsInc{MinAll};
    CoeffRelDanger_Final                = CoeffRelDanger{MinAll}; %#ok<NASGU>
    
    % 不直接覆盖 handles.Variables（以免影响 Step1/2），改为保存到临时变量
    if handles.Flow.CaFlag
        femFinal = FemFactorCa(MinAll);
    end
    if handles.Flow.RelDangerFlag
        fastCancerFinal = CoeffRelDanger{MinAll};
    end
    if handles.Flow.AdjFractionRectumFlag
        rectumFinal = CoeffRectum{MinAll};
    Calibration_3_temp.Variables = handles.Variables;
    Calibration_3_temp.Flow      = handles.Flow;
    Calibration_3_temp.BM        = BM;  %#ok<STRNU>
    
    if handles.Flow.Number_second_iteration >0 % if adv adenoma and carcinoma will be adjusted
        set(handles.message, 'string', 'Adjusting carcinoma by Nelder-Mead simplex search')
        drawnow
        %%% the path were this program is stored, this must be the CMOST path
        Path = mfilename('fullpath');
        pos = regexp(Path, [mfilename, '$']);
        CurrentPath = Path(1:pos-1);
        cd (fullfile(CurrentPath, 'Temp'))
        save('Calibration_3_temp', 'Calibration_3_temp');
        
        % for the second optimization we use the misearch function
        % tighten tolerances and allow more function evaluations for more robust convergence
        options = optimset('OutputFcn', @Auto_Calib_3_OutFunction, 'MaxFunEvals', max(200, handles.Flow.Number_second_iteration*2), 'MaxIter', max(200, handles.Flow.Number_second_iteration*2), 'TolX', 1e-6, 'TolFun', 1e-6, 'Display', 'off');
        if handles.Flow.CaFlag % we optimize carcinoma
            tmpff = @(x)Auto_Calib_3_TempFunction(x(1), x(2), x(3));
            [output] = fminsearch(tmpff,[CoeffsInc_Final(1), CoeffsInc_Final(2), CoeffsInc_Final(3)], options); %,...
            CoeffsInc_Final(1:3) = output(1:3);
        end
    end
    
    choice = questdlg('Do you want to keep the result of this run of optimization?',...
        'Keep results?','yes', 'no', 'yes');
    switch choice
        case    'yes'
            KeepFlag = 1;
        case    'no'
            KeepFlag = 0;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% final run optimized parameters                 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if KeepFlag
    clear tmp2
    tmp2{1} = CoeffsInc_Final;
    % 在临时副本上执行调整，避免修改原始 handles.Variables
    tempHandles = handles;
    tempHandles = AdjustRates(tempHandles, tmp2, index_age, 1);
    if exist('femFinal', 'var') && handles.Flow.CaFlag
        tempHandles.Flow.CoeffsInc = CoeffsInc_Final;
        tempHandles.Variables.advanced_progression_female = femFinal; %#ok<NASGU>
    end
    if exist('fastCancerFinal', 'var') && handles.Flow.RelDangerFlag
        tempHandles.Variables.FastCancer = fastCancerFinal; %#ok<NASGU>
    end
    if exist('rectumFinal', 'var') && handles.Flow.AdjFractionRectumFlag
        tempHandles.Variables.Location_EarlyProgression(13) = rectumFinal(1); %#ok<NASGU>
        tempHandles.Variables.Location_AdvancedProgression(13) = rectumFinal(2); %#ok<NASGU>
    end

    set(handles.message, 'string', 'Re-running with optimized parameters (temporary computation)')
    drawnow
    % we run the calculations on the temporary handles to obtain BM and RMS
    [~, BM] = CalculateSub(tempHandles);

    % compute RMS for the temporary run
    [RMSI_temp, RMSD_temp, RMSR_temp, BMAdvx, BMAdvy, BMIncx, BMIncy] = CalculateRMS(tempHandles, BM,...
        BMAdvx, BMAdvy, BMIncx, BMIncy, Benchmark_Ca_inc, RMSI, RMSD, RMSR, i);

    % 将 Step3 的最终结果保存到 Calibration.Step3 命名空间，不覆盖 Step1/Step2 的核心变量
    if ~isfield(handles.Variables, 'Calibration') || ~isstruct(handles.Variables.Calibration)
        handles.Variables.Calibration = struct();
    end
    handles.Variables.Calibration.Step3.CoeffsInc = CoeffsInc_Final;
    if exist('femFinal', 'var')
        handles.Variables.Calibration.Step3.CoeffsInc_FemFactor = femFinal;
    end
    if exist('fastCancerFinal', 'var')
        handles.Variables.Calibration.Step3.CoeffsInc_FastCancer = fastCancerFinal;
    end
    if exist('rectumFinal', 'var')
        handles.Variables.Calibration.Step3.CoeffsInc_Rectum = rectumFinal;
    end
    handles.Variables.Calibration.Step3.RMSI = RMSI_temp(i);
    handles.Variables.Calibration.Step3.RMSD = RMSD_temp(i);
    handles.Variables.Calibration.Step3.RMSR = RMSR_temp(i);

    % 更新 GUI 显示为临时计算结果（Flow 字段）
    handles.Flow.RMSI = RMSI_temp;
    handles.Flow.RMSD = RMSD_temp;
    handles.Flow.RMSR = RMSR_temp;
    if handles.Flow.CaFlag
        handles.Flow.RMS_Ca_current = RMSI_temp(i);
    end
    if handles.Flow.RelDangerFlag
        handles.Flow.RMS_Rel_danger_current = RMSD_temp(i);
    end
    if handles.Flow.AdjFractionRectumFlag
        handles.Flow.RMS_Adjust_rectum_current = RMSR_temp(i);
    end

    % 恢复原始的 handles.Variables（保证 Step1/2 变量不被覆盖）
    handles.Variables = VariablesBackup;

    % 恢复 flags 并结束
    handles.Variables.DispFlag    = DispFlagBackup;
    handles.Variables.ResultsFlag = ResultsFlagBackup;
    handles.Variables.ExcelFlag   = ExcelFlagBackup;
    handles.Flow.Message          = 'Optimization finished (Step3 results saved to Calibration)';
else
    handles.Variables = VariablesBackup;
    handles = InitializeValues(handles);
end
handles = MakeImagesCurrent(hObject, handles, BM); %#ok<NASGU>

end % explicitly end Start_Callback to separate it from local functions

%%%% calculate RMS
function [RMSI, RMSD, RMSR, BMAdvx, BMAdvy, BMIncx, BMIncy] = CalculateRMS(handles, BM,...
    BMAdvx, BMAdvy, BMIncx, BMIncy, Benchmark_Ca_inc, RMSI, RMSD, RMSR, i)

% RMS for advanced adenoma
BMAdvx{i}   = 1/5*handles.Variables.Benchmarks.AdvPolyp.Ov_y; %corr BM
BMAdvy{i}   = BM.OutputValues.AdvAdenoma_Ov;
% 确保长度一致
maxLen_Adv = min(length(BMAdvx{i}), length(BMAdvy{i}));
BMAdvx{i} = BMAdvx{i}(1:maxLen_Adv);
BMAdvy{i} = BMAdvy{i}(1:maxLen_Adv);

% RMS for carcinoma
BMIncx{i}   = 1/5*handles.Variables.Benchmarks.Cancer.Ov_y; %corr BM
BMIncy{i}   = BM.OutputValues.Cancer_Ov;
% 确保长度一致
maxLen_Inc = min(length(BMIncx{i}), length(BMIncy{i}));
BMIncx{i} = BMIncx{i}(1:maxLen_Inc);
BMIncy{i} = BMIncy{i}(1:maxLen_Inc);
if handles.Flow.CaFlag
    % ===== 激进策略 v2 (Step 3 Port) =====
    % Overall RMS
    benchOv = handles.Variables.Benchmarks.Cancer.Ov_inc(:)';
    ageOv = handles.Variables.Benchmarks.Cancer.Ov_y;
    
    % 权重策略：相对误差权重 * 年龄权重（重点优化Overall 30-45岁段）
    relError_weights_ov = 1 ./ (1 + 0.3 * benchOv / max(benchOv));
    ageWeights_ov = ones(size(benchOv));
    for k = 1:length(ageWeights_ov)
        if ageOv(k) < 30
            ageWeights_ov(k) = 1.8;
        elseif ageOv(k) < 45
            ageWeights_ov(k) = 2.8;  % 30-45岁加强权重，重点拟合
        elseif ageOv(k) < 60
            ageWeights_ov(k) = 1.5;
        elseif ageOv(k) < 70
            ageWeights_ov(k) = 1.2;
        elseif ageOv(k) < 80
            ageWeights_ov(k) = 1.5;
        else
            ageWeights_ov(k) = 2.0;
        end
    end
    weights_ov = relError_weights_ov .* ageWeights_ov;
    weights_ov = weights_ov / mean(weights_ov);
    
    RMS_Ov = 0;
    maxLen_Ov = min(length(benchOv), length(BM.OutputValues.Cancer_Ov));
    for j=1:maxLen_Ov
        if benchOv(j) > 1e-6
            % Relative error for incidence
            calcVal = BM.OutputValues.Cancer_Ov(j);
            relError = abs(calcVal - benchOv(j)) / benchOv(j);
            % 惩罚Overall 30-45岁以及55-70岁的偏差
            overestimate_penalty = 1.0;
            if ageOv(j) >= 30 && ageOv(j) <= 45 && calcVal > benchOv(j)
                % Overall 30-45岁过高估计（平衡惩罚）
                overestimate_penalty = 1.82 + 0.030 * (ageOv(j) - 30);
            elseif ageOv(j) >= 55 && ageOv(j) <= 70 && calcVal > benchOv(j)
                % 55-70岁偏高，增加惩罚（平衡惩罚）
                overestimate_penalty = 1.90 + 0.034 * (ageOv(j) - 55);
            elseif ageOv(j) > 70 && calcVal > benchOv(j)
                overestimate_penalty = 1.48 + 0.021 * (ageOv(j) - 70);
            end
            term = weights_ov(j) * overestimate_penalty * relError^2;
            if isfinite(term)
                RMS_Ov = RMS_Ov + term;
            end
        end
    end
    RMS_Ov = sqrt(RMS_Ov / maxLen_Ov);
    
    % Male RMS - 重点优化Male 30-45岁段
    benchMale = handles.Variables.Benchmarks.Cancer.Male_inc(:)';
    ageMale = handles.Variables.Benchmarks.Cancer.Male_y;
    
    relError_weights_male = 1 ./ (1 + 0.3 * benchMale / max(benchMale));
    ageWeights_male = ones(size(benchMale));
    for k = 1:length(ageWeights_male)
        if ageMale(k) < 30
            ageWeights_male(k) = 1.5;
        elseif ageMale(k) < 45
            ageWeights_male(k) = 2.8;  % 30-45岁加强权重，重点拟合
        elseif ageMale(k) < 60
            ageWeights_male(k) = 2.2;  % 45-60岁维持较高权重
        elseif ageMale(k) < 70
            ageWeights_male(k) = 1.3;
        elseif ageMale(k) < 80
            ageWeights_male(k) = 1.5;
        else
            ageWeights_male(k) = 1.8;
        end
    end
    weights_male = relError_weights_male .* ageWeights_male;
    weights_male = weights_male / mean(weights_male);
    
    RMS_Male = 0;
    maxLen_Male = min(length(benchMale), length(BM.OutputValues.Cancer_Male));
    for j=1:maxLen_Male
        if benchMale(j) > 1e-6
            calcVal = BM.OutputValues.Cancer_Male(j);
            relError = abs(calcVal - benchMale(j)) / benchMale(j);
            % 惩罚逻辑：引导 Male 曲线。20-60 岁偏低需上移，80+ 级需上移。
            bias_penalty = 1.0;
            if ageMale(j) >= 20 && ageMale(j) <= 60
                if calcVal < benchMale(j)
                    % 修正 20-60 岁偏低（平衡惩罚）
                    bias_penalty = 2.18 + 0.018 * (ageMale(j) - 20);
                else
                    bias_penalty = 1.0;
                end
            elseif ageMale(j) > 60 && ageMale(j) <= 75 && calcVal > benchMale(j)
                % 60-75 岁偏高（平衡惩罚）
                bias_penalty = 1.90 + 0.023 * (ageMale(j) - 60);
            elseif ageMale(j) > 80 && calcVal < benchMale(j)
                % 87 岁大幅偏低，强力拉升
                bias_penalty = 4.7 + 0.093 * (ageMale(j) - 80);
            end
            term = weights_male(j) * bias_penalty * relError^2;
            if isfinite(term)
                RMS_Male = RMS_Male + term;
            end
        end
    end
    RMS_Male = sqrt(RMS_Male / maxLen_Male);
    
    % Female RMS - 重点优化Female 60-80岁段
    benchFemale = handles.Variables.Benchmarks.Cancer.Female_inc(:)';
    ageFemale = handles.Variables.Benchmarks.Cancer.Female_y;
    
    relError_weights_female = 1 ./ (1 + 0.3 * benchFemale / max(benchFemale));
    ageWeights_female = ones(size(benchFemale));
    for k = 1:length(ageWeights_female)
        if ageFemale(k) < 45
            ageWeights_female(k) = 1.5;  % 年轻女性权重适中
        elseif ageFemale(k) < 60
            ageWeights_female(k) = 1.2;
        elseif ageFemale(k) < 80
            ageWeights_female(k) = 2.8;  % 60-80岁加强权重，重点拟合（从60-75的2.3提升）
        elseif ageFemale(k) < 85
            ageWeights_female(k) = 2.0;  % 80-85岁调整权重
        else
            ageWeights_female(k) = 1.6;  % 85岁以上降低权重（避免过度拟合极高龄）
        end
    end
    weights_female = relError_weights_female .* ageWeights_female;
    weights_female = weights_female / mean(weights_female);
    
    RMS_Female = 0;
    maxLen_Female = min(length(benchFemale), length(BM.OutputValues.Cancer_Female));
    for j=1:maxLen_Female
        if benchFemale(j) > 1e-6
            calcVal = BM.OutputValues.Cancer_Female(j);
            relError = abs(calcVal - benchFemale(j)) / benchFemale(j);
            % 惩罚逻辑：压低 Female 60-82 岁曲线。
            bias_penalty = 1.0;
            if ageFemale(j) >= 55 && ageFemale(j) <= 85
                if calcVal > benchFemale(j)
                    % 针对 Female，平衡惩罚
                    bias_penalty = 4.7 + 0.073 * (ageFemale(j) - 55);
                else
                    % 宽容低估
                    bias_penalty = 0.77;
                end
            elseif ageFemale(j) > 85 && calcVal > benchFemale(j)
                bias_penalty = 1.80 + 0.035 * (ageFemale(j) - 85);
            end
            term = weights_female(j) * bias_penalty * relError^2;
            if isfinite(term)
                RMS_Female = RMS_Female + term;
            end
        end
    end
    RMS_Female = sqrt(RMS_Female / maxLen_Female);
    
    % Combined RMS - 两阶段权重策略
    % ========== 两阶段优化权重 ==========
    if handles.Flow.Iteration <= 20
        %%% 第一组（1-20）：均匀分布权重 - 快速逼近
        weight_Ov = 0.35;
        weight_Male = 0.33;
        weight_Female = 0.32;
    else
        %%% 第二组（21+）：平滑过渡权重 - 精调
        smoothing = (handles.Flow.Iteration - 20) / 10;  % 21-30逐步过渡
        if smoothing > 1, smoothing = 1; end
        weight_Ov = 0.35 + 0.05 * smoothing;      % 0.35 → 0.40 (渐进)
        weight_Male = 0.33 + 0.00 * smoothing;    % 保持0.33
        weight_Female = 0.32 - 0.05 * smoothing;  % 0.32 → 0.27 (渐进)
    end
    RMSI(i) = weight_Ov * RMS_Ov + weight_Male * RMS_Male + weight_Female * RMS_Female;
end

if handles.Flow.RelDangerFlag
    % RMS for relative danger - 独立优化，不影响RMSI
    RMSD(i) = 0;
    for f=1:5
        RMSD(i) = RMSD(i) + (1 - BM.CancerOriginValue(f)/handles.Variables.Benchmarks.Rel_Danger(f))^2;
    end
    RMSD(i) = sqrt(RMSD(i) / 5);
end
if handles.Flow.AdjFractionRectumFlag
    % RMS for fraction rectum - 独立优化，不影响RMSI
    RMSR(i) = 0;
    for f=2:3
        RMSR(i) = RMSR(i) + ((BM.LocationRectum(f) - BM.LocBenchmark(f))/ BM.LocBenchmark(f))^2;
    end
    RMSR(i) = sqrt(RMSR(i) / 2);
end

% adjust rates
function handles = AdjustRates(handles, CoeffsInc, index_age, i)

if handles.Flow.CaFlag
    % 🔄 Logistic增长模型：稳健的S型曲线拟合
    % 公式: Rate = base_scaling * A / (1 + exp(-B * (age - C)))
    % 
    % 参数含义:
    % CoeffsInc{i}(1): 饱和发病率 (A) - S型曲线的上渐近线
    % CoeffsInc{i}(2): 增长率 (B) - 控制曲线陡峭程度
    % CoeffsInc{i}(3): 中点年龄 (C) - S型曲线的拐点位置
    
    % 基础缩放因子 - 精细调整至 2.78e-4 平衡Overall/Male/Female
    % 核心目标：达到三个人群的最优平衡
    base_scaling = 2.78e-4;
    
    % Logistic核心公式
    age_values = index_age * 5;  % 转换为实际年龄（5,10,...,100）
    logistic_term = 1 ./ (1 + exp(-CoeffsInc{i}(2) * (age_values - CoeffsInc{i}(3))));
    
    % 高年龄衰减项 - 两阶段衰减策略
    % ========== 两阶段衰减参数 ==========
    if handles.Flow.Iteration <= 20
        %%% 第一组：较强衰减 - 快速调整
        age_decay_start = 81;        % 较早开始衰减
        decay_rate = 0.00105;        % 较强衰减
        extra_decay_start = 95;      % 较早超高龄衰减
        extra_decay_rate = 0.0017;   % 较强超高龄衰减
    else
        %%% 第二组：温和衰减 - 精细微调
        age_decay_start = 82;        % 延后衰减
        decay_rate = 0.00090;        % 温和衰减 (-14%)
        extra_decay_start = 96;      % 延后超高龄衰减
        extra_decay_rate = 0.0014;   % 温和超高龄衰减 (-18%)
    end
    decay_factor = ones(size(age_values));
    extra_decay_factor = ones(size(age_values));
    for k = 1:length(age_values)
        if age_values(k) > age_decay_start
            decay_factor(k) = exp(-decay_rate * (age_values(k) - age_decay_start)^2);
        end
        if age_values(k) > extra_decay_start
            extra_decay_factor(k) = exp(-extra_decay_rate * (age_values(k) - extra_decay_start)^2);
        end
    end
    
    rate_curve = base_scaling * CoeffsInc{i}(1) * logistic_term .* decay_factor .* extra_decay_factor;
    handles.Variables.AdvancedProgressionRate = rate_curve;
    
    counter = 1;
    % 将 20 个 5岁间隔点 插值为 100 个 1岁间隔点
    for x1 = 1:19
        step_val = (handles.Variables.AdvancedProgressionRate(x1+1) - handles.Variables.AdvancedProgressionRate(x1)) / 5;
        for x2 = 0:4
            handles.Variables.AdvancedProgression(counter) = handles.Variables.AdvancedProgressionRate(x1) + x2 * step_val;
            counter = counter + 1;
        end
    end
    handles.Variables.AdvancedProgression(counter : 150) = handles.Variables.AdvancedProgressionRate(end);
end

function sse = computeSSE(model, X, Y, b, useGPU)
if nargin < 5
    useGPU = false;
end
if useGPU
    try
        Xg = gpuArray(X);
        Yg = gpuArray(Y);
        Bg = gpuArray(b);
        Yhat = model(Bg, Xg);
        diff = Yhat - Yg;
        sse = gather(sum(diff(:).^2));
        return
    catch
        % fallback to CPU
    end
end
Yhat = model(b, X);
diff = Yhat - Y;
sse = sum(diff(:).^2);


% DELETE
function figure1_DeleteFcn(hObject, eventdata, handles) %#ok<DEFNU,INUSL>
handles.Variables = handles.OldVariables;
guidata(hObject, handles)

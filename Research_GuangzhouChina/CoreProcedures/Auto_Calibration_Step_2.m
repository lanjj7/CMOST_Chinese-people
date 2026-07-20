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

function varargout = Auto_Calibration_Step_2(varargin)

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Auto_Calibration_Step_2_OpeningFcn, ...
                   'gui_OutputFcn',  @Auto_Calibration_Step_2_OutputFcn, ...
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
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    Opening function                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function Auto_Calibration_Step_2_OpeningFcn(hObject, ~, handles, varargin)

handles.Variables = get(0, 'userdata');
handles.OldVariables = handles.Variables;
handles = InitializeValues(handles);

% 更新窗口标题显示数据来源
set(handles.figure1, 'Name', 'Auto Calibration Step 2: Advanced Adenoma (温州ADR数据)');

handles.output = hObject;
handles = MakeImagesCurrent(hObject, handles, handles.BM);
guidata(hObject, handles);
uiwait(handles.figure1);
end

function handles = InitializeValues(handles)
% we initialize flow variables
handles.Flow.StopFlag = 'off';
handles.Flow.Iteration = 1;
handles.Flow.RMS_Adv_current            =0;
handles.Flow.RMS_Ad_distr_current       =0;

handles.Flow.RMSA   = 0;
handles.Flow.RMSP   = 0;
handles.Flow.Message = 'Press Start for automated parameter optimization';

handles.Flow.AdFlag                = 1;
handles.Flow.DistFlag              = 1;

handles.Flow.Number_first_iteration  = 3;   % 第一次迭代次数
handles.Flow.Number_second_iteration = 60;   % 第二次Nelder-Mead迭代次数

% we initialize variables for the advanced adenoma prevalence graphs
handles.BM.Graph.AdvAdenoma_Ov     = zeros(1, 100);
handles.BM.Graph.AdvAdenoma_Male   = zeros(1, 100);
handles.BM.Graph.AdvAdenoma_Female = zeros(1, 100);

% adenoma stage distribution 
handles.BM.Polyp_adv        = zeros(6,1);
handles.BM.BM_value_adv     = zeros(6,1);    
for f=1:6
    handles.BM.Pflag{f}            = 'red';
end

for f=1:length(handles.Variables.Benchmarks.AdvPolyp.Ov_y)
    handles.BM.OutputFlags.AdvAdenoma_Ov {f} = 'red';
end
for f=1:length(handles.Variables.Benchmarks.AdvPolyp.Male_y)
    handles.BM.OutputFlags.AdvAdenoma_Male   {f} = 'red';
end
for f=1:length(handles.Variables.Benchmarks.AdvPolyp.Female_y)
    handles.BM.OutputFlags.AdvAdenoma_Female {f} = 'red';
end

handles.BM.OutputValues.AdvAdenoma_Ov     = zeros(1, length(handles.Variables.Benchmarks.AdvPolyp.Ov_y));
handles.BM.OutputValues.AdvAdenoma_Male   = zeros(1, length(handles.Variables.Benchmarks.AdvPolyp.Male_y));
handles.BM.OutputValues.AdvAdenoma_Female = zeros(1, length(handles.Variables.Benchmarks.AdvPolyp.Female_y));
end

function varargout = Auto_Calibration_Step_2_OutputFcn(hObject, eventdata, handles) %#ok<INUSL
handles.output = 1;
varargout{1} = handles.output;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make Images current                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% this functions makes all chages to values visible
function handles = MakeImagesCurrent(hObject, handles, BM)
% This function is called whenever a change is made within the GUI. This 
% function makes these changes visible

% Check if figure still exists before updating GUI
if ~isfield(handles, 'figure1') || ~isvalid(handles.figure1)
    return;
end

FontSz   = 10;
MarkerSz = 5;
LineSz   = 0.4;

set(handles.Stop, 'enable', 'on');

set(handles.RMS_AdvAd_current, 'string', num2str(handles.Flow.RMS_Adv_current), 'enable', 'off')
set(handles.RMS_distribution_current, 'string', num2str(handles.Flow.RMS_Ad_distr_current), 'enable', 'off')

set(handles.Iteration_number, 'string', num2str(handles.Flow.Iteration), 'enable', 'off')

% we adjust the flags which parameter will be adjusted
set(handles.AdjAdvAdFlag, 'value', handles.Flow.AdFlag)
set(handles.AdjAdDistrFlag, 'value', handles.Flow.DistFlag)

set(handles.Number_first_iteration, 'string', num2str(handles.Flow.Number_first_iteration)) %#ok<
set(handles.Number_second_iteration, 'string', num2str(handles.Flow.Number_second_iteration)) %#ok<
set(handles.message, 'string', handles.Flow.Message)

% Advanced adenoma graphs        
% overall
MakeGraphik(handles.Adv_Ov_Axes, BM.Graph.AdvAdenoma_Ov, handles.Variables.Benchmarks.AdvPolyp.Ov_y,...
    handles.Variables.Benchmarks.AdvPolyp.Ov_perc, BM.OutputValues.AdvAdenoma_Ov,...
    BM.OutputFlags.AdvAdenoma_Ov, 'Prevalence adenoma overall', 'percent of patients', LineSz, MarkerSz, FontSz, 'Ad')

% male
MakeGraphik(handles.Adv_Male_Axes, BM.Graph.AdvAdenoma_Male, handles.Variables.Benchmarks.AdvPolyp.Male_y,...
    handles.Variables.Benchmarks.AdvPolyp.Male_perc, BM.OutputValues.AdvAdenoma_Male,...
    BM.OutputFlags.AdvAdenoma_Male, 'Prevalence adenoma male', 'percent of patients', LineSz, MarkerSz, FontSz, 'Ad')

% female
MakeGraphik(handles.Adv_Female_Axes, BM.Graph.AdvAdenoma_Female, handles.Variables.Benchmarks.AdvPolyp.Female_y,...
    handles.Variables.Benchmarks.AdvPolyp.Female_perc, BM.OutputValues.AdvAdenoma_Female,...
    BM.OutputFlags.AdvAdenoma_Female, 'Prevalence adenoma female', 'percent of patients', LineSz, MarkerSz, FontSz, 'Ad')
guidata(hObject, handles);

% Adenoma distribution - 使用 set 而不是 axes 以避免窗口弹出
set(handles.figure1, 'CurrentAxes', handles.Adenoma_distribution);
cla(handles.Adenoma_distribution)
bar(cat(2, BM.Polyp_adv, zeros(6,1), BM.BM_value_adv)', 'stacked'), hold on
for f=5:6 
    if isequal(f, 5), LinePos(f) = BM.Polyp_adv(f)/2; %#ok<AGROW>
    else LinePos(f) = sum(BM.Polyp_adv(5:f-1))+BM.Polyp_adv(f)/2; %#ok<AGROW>
    end
end
for f=5:6
    line([1.5 2.5], [LinePos(f) LinePos(f)], 'color', BM.Pflag{f})
end    
l=legend('Adenoma 3mm', 'Adenoma 5mm', 'Adenoma 7mm', 'Adenoma 9mm', 'Adv Adenoma P5', 'Adv Adenoma P6');
set(l, 'location', 'northoutside', 'fontsize', FontSz)
ylabel('% of affected patients', 'fontsize', FontSz)
title('distribution of P5/ P6 adenoma stages')
set(gca, 'xticklabel', {'adenomas' '' 'benchmark' ''}, 'fontsize', FontSz, 'ylim', [0 100])
    
% Adjusting RMS Graph advanced - 使用 set 而不是 axes
set(handles.figure1, 'CurrentAxes', handles.RMS_Adv);
cla(handles.RMS_Adv)
% 只绘制有效的迭代次数
valid_idx = find(handles.Flow.RMSA ~= 0, 1, 'last');
if isempty(valid_idx), valid_idx = 1; end
plot(1:valid_idx, handles.Flow.RMSA(1:valid_idx)), hold on
title('RMS adv. ad. prevalence')
for f=1:valid_idx
    plot(f, handles.Flow.RMSA(f), '--rs','LineWidth',1, 'MarkerEdgeColor','k', 'MarkerFaceColor','g', 'MarkerSize',3)
end 
set(gca, 'color',  [0.6 0.6 1], 'box', 'off')

% Adjusting RMS adenoma distribution - 使用 set 而不是 axes
set(handles.figure1, 'CurrentAxes', handles.RMS_distribution);
cla(handles.RMS_distribution)
% 只绘制有效的迭代次数
valid_idx_p = find(handles.Flow.RMSP ~= 0, 1, 'last');
if isempty(valid_idx_p), valid_idx_p = 1; end
plot(1:valid_idx_p, handles.Flow.RMSP(1:valid_idx_p)), hold on
title('RMS ad. stage distribution')
for f=1:valid_idx_p
    plot(f, handles.Flow.RMSP(f), '--rs','LineWidth',1, 'MarkerEdgeColor','k', 'MarkerFaceColor','g', 'MarkerSize',3)
end 
set(gca, 'color',  [0.6 0.6 1], 'box', 'off')
drawnow limitrate nocallbacks
end

function MakeGraphik(AxHandle, DataGraph, BM_year, BM_value, BM_current, BM_flags, GraphTitle, LabelY, LineSz, MarkerSz, FontSz, Mod)
% 使用 set 而不是 axes 以避免窗口弹出
fig = ancestor(AxHandle, 'figure');
if ~isempty(fig) && isvalid(fig)
    set(fig, 'CurrentAxes', AxHandle);
end
cla(AxHandle) 
if isequal(Mod, 'Ca')
    plot(BM_year, DataGraph, 'color', 'k'), hold on
else
    plot(0:99, DataGraph, 'color', 'k'), hold on
end
plot(BM_year, BM_value, '--bs','LineWidth',LineSz, 'MarkerEdgeColor','k', 'MarkerFaceColor','b', 'MarkerSize',MarkerSz)

for f=1:length(BM_year)
    if isequal(BM_flags{f}, '')
        BM_flags{f} = 'black';
    end
    plot(BM_year(f), BM_current(f), '--rs', 'LineWidth', LineSz, 'MarkerEdgeColor','k', 'MarkerFaceColor', BM_flags{f}, 'MarkerSize',3)
    line([BM_year(f)-2 BM_year(f)+2], [BM_current(f) BM_current(f)], 'color', BM_flags{f});
end
xlabel('year', 'fontsize', FontSz), ylabel(LabelY, 'fontsize', FontSz), title(GraphTitle, 'fontsize', FontSz)

% 自动调整Y轴范围以显示所有数据点
allYData = [DataGraph(:); BM_value(:); BM_current(:)];
allYData = allYData(~isnan(allYData) & ~isinf(allYData));
if ~isempty(allYData)
    yMin = min(allYData);
    yMax = max(allYData);
    yRange = yMax - yMin;
    if yRange < 0.1, yRange = 1; end  % 防止范围太小
    yLimLow = max(0, yMin - 0.1*yRange);
    yLimHigh = yMax + 0.1*yRange;
    set(gca, 'ylim', [yLimLow yLimHigh])
end
set(gca, 'xlim', [0 100], 'fontsize', FontSz, 'xtick', [0 20 40 60 80 100])
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% First and second iteration         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function Number_first_iteration_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
tmp=get(handles.Number_first_iteration, 'string'); [num, succ] =str2num(tmp); %#ok<ASGLU,ST2NM>
handles.Flow.Number_first_iteration = abs(round(num));
handles = MakeImagesCurrent(hObject, handles, handles.BM); %#ok<NASGU>
end

function Number_second_iteration_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
tmp=get(handles.Number_second_iteration, 'string'); [num, succ] =str2num(tmp);%#ok<ASGLU,ST2NM>
handles.Flow.Number_second_iteration = abs(round(num));
handles = MakeImagesCurrent(hObject, handles, handles.BM); %#ok<NASGU>
end

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
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Stop                               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function Stop_Callback(hObject, eventdata, handles) %#ok<DEFNU,INUSL>
set(handles.Stop, 'enable', 'off');
guidata(hObject, handles)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Flags for adjustments              %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function AdjAdvAdFlag_Callback(hObject, ~, handles) %#ok<DEFNU>
handles.Flow.AdFlag = get(handles.AdjAdvAdFlag, 'value');
handles = MakeImagesCurrent(hObject, handles, handles.BM); %#ok<NASGU>
end

function AdjAdDistrFlag_Callback(hObject, ~, handles) %#ok<DEFNU>
handles.Flow.DistFlag = get(handles.AdjAdDistrFlag, 'value'); 
handles = MakeImagesCurrent(hObject, handles, handles.BM); %#ok<NASGU>
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create Functions and non-functional callbacks  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function Iteration_number_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
end

function RMS_AdvAd_current_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
end

function RMS_distribution_current_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
end

function RMS_distribution_current_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
end

function RMS_AdvAd_current_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
end

function Iteration_number_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
end

function Number_first_iteration_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
end

function Number_second_iteration_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Start                              %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function Start_Callback(hObject, ~, handles) %#ok<DEFNU>
% BM.Polyp_adv, zeros(6,1), BM.BM_value_adv
if ~or(handles.Flow.AdFlag, handles.Flow.DistFlag)
    return % we return if no optimization is selected
end

% 确保Stop按钮在开始时是启用的
set(handles.Stop, 'enable', 'on');
guidata(hObject, handles);

% we get started
handles.Flow.Message = sprintf('Approaching optimimum: best of %d steps will be used', handles.Flow.Number_first_iteration);
if isfield(handles, 'message') && isvalid(handles.message)
    set(handles.message, 'string', handles.Flow.Message)
    drawnow
end

% we backup the flags

DispFlagBackup    = handles.Variables.DispFlag;
ResultsFlagBackup = handles.Variables.ResultsFlag;
ExcelFlagBackup   = handles.Variables.ExcelFlag;
VariablesBackup   = handles.Variables;
NumberPatientsBackup = handles.Variables.Number_patients; % 保存原始模拟人数

handles.Variables.DispFlag     = 0;
handles.Variables.ResultsFlag  = 0;
handles.Variables.ExcelFlag    = 0;

% 增加模拟人数以减少随机噪声，提高RMS精度
handles.Variables.Number_patients = 50000;

% 启动并行池（如果可用）以加速计算
try
    pool = gcp('nocreate');
    if isempty(pool)
        % 获取可用核心数，并限制不超过集群最大工作进程
        numCores = feature('numcores');
        c = parcluster('local');
        numWorkers = min(numCores, c.NumWorkers);
        poolObj = parpool('local', numWorkers, 'SpmdEnabled', false);
        fprintf('已启动并行池，使用 %d 个核心\n', numWorkers);
    end
catch ME
    fprintf('无法启动并行池: %s\n', ME.message);
    % 如果无法启动并行池，继续串行执行
end

index_age=1:20;

% we initialize variables for tracking RMS - 预分配数组以避免索引错误
max_iterations = handles.Flow.Number_first_iteration + 10;
RMSA = zeros(1, max_iterations); % for advanced adenoma
RMSP = zeros(1, max_iterations); % for adenoma distribution

EAdv = cell(1,1);
BMAdvx = cell(1,1); BMAdvy = cell(1,1); BMIncx = cell(1,1); BMIncy = cell(1,1);

i_sigmoid = @(A,u) A(1)./(1 + exp(-(u*A(2)-A(3))));
fit_sigmoid = @(u,y,p0) multiStartSigmoidFit(u, y, p0, i_sigmoid);

i=1; % first iteration

Benchmark_AdvAd_y    = 1/5 * handles.Variables.Benchmarks.AdvPolyp.Ov_y;
Benchmark_AdvAd_perc = handles.Variables.Benchmarks.AdvPolyp.Ov_perc;

% if coefficients have already been calculated we use those
if isfield(handles.Flow, 'CoeffsAdv')
    CoeffsAdv{1} = handles.Flow.CoeffsAdv;
    EAdv_Start   = handles.Flow.CoeffsAdv;
else
    % 初值优化：使用多个低龄优化的初始参数获得最优拟合
    % 这些参数组合特别适合低年龄段的缓和增长
    CoeffsAdv{1} = fit_sigmoid(Benchmark_AdvAd_y, Benchmark_AdvAd_perc, [4 1.8 18]);
    EAdv_Start   = CoeffsAdv{1};
end

if handles.Flow.AdFlag
    % 使用与 AdjustRates 函数一致的系数 (0.04，无 1.5x 乘数)
    handles.Variables.EarlyProgressionRate = 0.04*CoeffsAdv{1}(1).*exp(-0.01*CoeffsAdv{1}(2)*( index_age - CoeffsAdv{1}(3) ).^2);
    counter = 1;
    for x1=1:19
        for x2=1:5
            handles.Variables.EarlyProgression(counter) = (handles.Variables.EarlyProgressionRate(x1) * (5-x2) + ...
                handles.Variables.EarlyProgressionRate(x1+1) * (x2-1))/4;
            counter = counter + 1;
        end
    end
    handles.Variables.EarlyProgression(counter : 150) = handles.Variables.EarlyProgressionRate(end);
end

% first run
[~, BM]=CalculateSub(handles);

% we get the RMS values
[RMSA, RMSP, BMAdvx, BMAdvy] = CalculateRMS(handles, BM, BMAdvx,...
    BMAdvy, Benchmark_AdvAd_perc, RMSA, RMSP, i);
    

lastwarn('');
B = fit_sigmoid(BMAdvx{i}, BMAdvy{i}, [10 1 10]);
if ~isempty(lastwarn) || ~all(isfinite(B))
    B = fit_sigmoid(BMAdvx{i}, BMAdvy{i}, [10 -1 -10]);
end
EAdv{i}=B;

% 优化学习率以更精确收敛
exp_arg = -0.05*(EAdv{i}(1)-EAdv_Start(1)); % 降低学习率以提高稳定性
exp_arg = max(min(exp_arg, 10), -10); % 限制在 [-10, 10] 防止溢出
CoeffsAdv{i+1}(1) = CoeffsAdv{i}(1)*exp(exp_arg);
CoeffsAdv{i+1}(2) = CoeffsAdv{i}(2)-0.05*(EAdv{i}(2)-EAdv_Start(2)); % 降低学习率
CoeffsAdv{i+1}(3) = CoeffsAdv{i}(3)+0.05*(EAdv{i}(3)-EAdv_Start(3)); % 降低学习率

% we save the factors by which adjustments for females are made
FemFactorAdv(i) = handles.Variables.early_progression_female;

% we save the start vectors for adenoma progression
CoeffPStage{i}         = handles.Variables.Progression;
ProgressionCoefficient = handles.Variables.Progression(5);

% we put the results to the graphical user interphase
handles.Flow.RMSA                    = RMSA;
handles.Flow.RMSP                    = RMSP;

if handles.Flow.AdFlag
    handles.Flow.RMS_Adv_current     = RMSA(i);
end
if handles.Flow.DistFlag
    handles.Flow.RMS_Ad_distr_current = RMSP(i);
end
handles.Flow.Iteration = i;
handles = MakeImagesCurrent(hObject, handles, BM);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% first run with educated guesses                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

KeepFlag = -1;
stagnation_count = 0;  % 🆕 停滞计数器
stagnation_threshold = 3;  % 🆕 连续3次改进不足则认为停滞

if handles.Flow.Number_first_iteration >2
    for i=2:handles.Flow.Number_first_iteration
        drawnow  % 改为 drawnow（不加limitrate），以便处理按钮点击事件
        % Check if GUI still exists
        if ~isfield(handles, 'figure1') || ~isvalid(handles.figure1)
            KeepFlag = 0;
            break;
        end
        
        % 重新获取handles以检测Stop按钮状态变化
        handles = guidata(hObject);
        
        if isfield(handles, 'Stop') && isvalid(handles.Stop) && isequal(get(handles.Stop, 'enable'), 'off')
            choice = questdlg('Do you want to keep the best result of this run of optimization?',...
                'Keep results?','yes', 'no', 'cancel', 'cancel');
            switch choice
                case    'yes'
                    KeepFlag = 1;
                    % we look for the best coefficients
                    tmp1 = sort(RMSA);
                    for f=1:length(RMSA), tmp1R(f)=find(tmp1==RMSA(f), 1); end %#ok<AGROW>
                    tmp2 = sort(RMSP);
                    for f=1:length(RMSP), tmp2R(f)=find(tmp2==RMSP(f), 1); end 
                    
                    tmp     = tmp1R + tmp2R;
                    if i>2
                        MinAll  = find(tmp == min(tmp(2:(i-1))), 1);
                    else
                        MinAll  = find(tmp == min(tmp), 1);
                    end
                    CoeffsAdv_Final                     = CoeffsAdv{MinAll};
                    CoffsPolypProgressionFinal          = CoeffPStage{MinAll};
                    if handles.Flow.AdFlag
                        handles.Variables.early_progression_female    = FemFactorAdv(MinAll);
                    end
                    i=i-1;
                    break
                case    'no'
                    KeepFlag = 0;
                    break
            end
        end
        if handles.Flow.DistFlag
            % we adjust progression rates for individual adenoma stages
            FactorP5(i) = 1; % (BM.BM_value_adv(5) / BM.Polyp_adv(5))^(1/4); %#ok<AGROW>
            handles.Variables.Progression(5)= handles.Variables.Progression(5) / FactorP5(i);
        end
        CoeffPStage{i} = handles.Variables.Progression;
        
        % adjusting rates for sdv adenoma and carcinoma is in a subroutine
        if handles.Flow.AdFlag
            handles = AdjustRates(handles, CoeffsAdv, index_age, i);
        end
        
        % the next run
        [~, BM]=CalculateSub(handles);
        
        % and we get the rms results
        [RMSA, RMSP, BMAdvx, BMAdvy] = CalculateRMS(handles, BM, BMAdvx,...
            BMAdvy, Benchmark_AdvAd_perc, RMSA, RMSP, i);
        
        % 检查 RMS 是否有效
        if ~isfinite(RMSA(i)) || RMSA(i) > 1e6
            fprintf('警告: RMSA(%d) = %f 异常，跳过此次迭代\n', i, RMSA(i));
            continue;
        end
        if ~isfinite(RMSP(i)) || RMSP(i) > 1e6
            fprintf('警告: RMSP(%d) = %f 异常，跳过此次迭代\n', i, RMSP(i));
            continue;
        end
        
        % the new coefficients for adenoma progression adenoma
        B = fit_sigmoid(BMAdvx{i}, BMAdvy{i}, [10 1 10]);
        if ~all(isfinite(B))
            B = fit_sigmoid(BMAdvx{i}, BMAdvy{i}, [10 -1 -10]);
        end
        EAdv{i}=B;
        
        % 🆕 检测RMS改进停滞（判断是否卡在局部最优）
        RMSA_improvement = (RMSA(i-1) - RMSA(i)) / max(RMSA(i-1), 0.001);  % 改进比例
        
        if RMSA_improvement < 0.0005  % 改进不足0.05%
            stagnation_count = stagnation_count + 1;
            fprintf('迭代%d: 改进停滞 (%.4f%%) [连续%d次]\n', i, RMSA_improvement*100, stagnation_count);
        else
            stagnation_count = 0;  % 重置计数器
        end
        
        % 改进的自适应学习率：根据停滞状态动态调整
        % 为系数3（转折点）设置平衡的学习率，确保稳定收敛
        
        if stagnation_count >= stagnation_threshold
            % 停滞时：适度降低学习率，保守探索
            lr1 = 0.07;   % A 幅度：降至0.07（从0.15降低）
            lr2 = 0.12;   % k 斜率：保持0.12（从0.25降低）
            lr3 = 0.18;   % x0 转折点：降至0.18（从0.35降低）
            fprintf('  → 停滞状态：使用保守学习率\n');
            stagnation_count = 0;  % 重置计数器
        else
            % 正常学习率：更平衡
            lr1 = 0.06;   % A 幅度：降至0.06（从0.08降低）
            lr2 = 0.09;   % k 斜率：降至0.09（从0.12降低）
            lr3 = 0.12;   % x0 转折点：降至0.12（从0.15降低）
        end
        
        exp_arg = -lr1*(EAdv{i}(1)-EAdv_Start(1));
        exp_arg = max(min(exp_arg, 10), -10);
        CoeffsAdv{i+1}(1) = CoeffsAdv{i}(1)*exp(exp_arg);
        CoeffsAdv{i+1}(2) = CoeffsAdv{i}(2)-lr2*(EAdv{i}(2)-EAdv_Start(2));
        CoeffsAdv{i+1}(3) = CoeffsAdv{i}(3)+lr3*(EAdv{i}(3)-EAdv_Start(3));
        % CoeffsAdv{i+1}(1) = CoeffsAdv{i}(1)*exp(-0.19*(EAdv{i}(1)-EAdv_Start(1))); %m -0.06*  %m 0.19
        % CoeffsAdv{i+1}(2) = CoeffsAdv{i}(2)-0.1*(EAdv{i}(2)-EAdv_Start(2));
        % CoeffsAdv{i+1}(3) = CoeffsAdv{i}(3)+0.1*(EAdv{i}(3)-EAdv_Start(3));
        % CoeffsAdv{i+1}(1) = CoeffsAdv{i}(1)*exp(-0.19*(EAdv{i}(1)-EAdv_Start(1))); %m -0.06*  %m 0.19
        % CoeffsAdv{i+1}(2) = CoeffsAdv{i}(2)-0.005*(EAdv{i}(2)-EAdv_Start(2));
        % CoeffsAdv{i+1}(3) = CoeffsAdv{i}(3)+0.005*(EAdv{i}(3)-EAdv_Start(3));
        
        if handles.Flow.AdFlag
            % we make adjustments ADVANCED ADENOMAS for females
            MaleSum = 0; FemaleSum = 0;
            for f = 1:length(handles.Variables.Benchmarks.AdvPolyp.Male_y)
                % we check, how much the male prevalence for early adenoma remains
                % above benchmarks
                MaleSum = MaleSum + (BM.OutputValues.AdvAdenoma_Male(f) - handles.Variables.Benchmarks.AdvPolyp.Male_perc(f))/...
                    handles.Variables.Benchmarks.AdvPolyp.Male_perc(f);
            end
            for f = 1:length(handles.Variables.Benchmarks.AdvPolyp.Female_y)
                % we check, how much the female prevalence for early adenoma remains
                % above benchmarks
                FemaleSum = FemaleSum + (BM.OutputValues.AdvAdenoma_Female(f) - handles.Variables.Benchmarks.AdvPolyp.Female_perc(f))/...
                    handles.Variables.Benchmarks.AdvPolyp.Female_perc(f);
            end
            FemaleSum = FemaleSum/length(handles.Variables.Benchmarks.AdvPolyp.Female_perc(f));
            MaleSum   = MaleSum/length(handles.Variables.Benchmarks.AdvPolyp.Male_perc(f));
            
            % 优化校正因子
            Factor = ((100-(FemaleSum - MaleSum))/100)^0.6; % 适度提高收敛速度
            handles.Variables.early_progression_female = handles.Variables.early_progression_female * Factor;
            
            FemFactorAdv(i) = handles.Variables.early_progression_female;
        end
        
        % we put the results to the graphical user interphase
        handles.Flow.RMSA                    = RMSA;
        handles.Flow.RMSP                    = RMSP;
        
        if handles.Flow.AdFlag
            handles.Flow.RMS_Adv_current     = RMSA(i);
        end
        if handles.Flow.DistFlag
            handles.Flow.RMS_Ad_distr_current = RMSP(i);
        end
        handles.Flow.Iteration       = i;
        handles                      = MakeImagesCurrent(hObject, handles, BM);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% second run Nelder Mead algorithm               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if isequal(KeepFlag, -1) % user did not interrupt
    % the next step will be fminsearch
    % we look for the best coefficients
    
    % 确保 RMSA 和 RMSP 是向量
    RMSA = RMSA(:)';
    RMSP = RMSP(:)';
    
    % 使用排名方法找到最佳组合
    [~, tmp1R] = sort(RMSA);
    [~, rank1] = sort(tmp1R);
    [~, tmp2R] = sort(RMSP);
    [~, rank2] = sort(tmp2R);
    
    tmp     = rank1 + rank2;
    if i>2
        MinAll  = find(tmp == min(tmp(2:(i-1))), 1);
    else
        MinAll  = find(tmp == min(tmp), 1);
    end
    CoeffsAdv_Final                     = CoeffsAdv{MinAll};
    ProgressionCoefficient              = CoeffPStage{MinAll}(5);
    
    if handles.Flow.AdFlag
        handles.Variables.early_progression_female    = FemFactorAdv(MinAll);
    end
    if handles.Flow.DistFlag
        handles.Variables.Progression = CoeffPStage{MinAll};
    end
    
    % we save data to be recovered by tempfunction and outfunction
    Calibration_2_temp.Variables = handles.Variables;
    Calibration_2_temp.Flow      = handles.Flow;
    Calibration_2_temp.BM        = BM;
    
    % 保存当前的最优系数作为先验，用于第二阶段优化时进行微弱正则化
    Calibration_2_temp.PriorCoeffs = CoeffsAdv_Final;
    Calibration_2_temp.PriorProgression = ProgressionCoefficient;
    Calibration_2_temp.PriorLambda = 0.005; % 正则化强度（较弱）
    
    % 重置第二阶段的迭代计数器（从0开始，TempFunction中会+1）
    Calibration_2_temp.Flow.Iteration = 0;
    Calibration_2_temp.Flow.Phase2_MaxIter = handles.Flow.Number_second_iteration;
    
    if handles.Flow.Number_second_iteration >0 % if adv adenoma and carcinoma will be adjusted
        if isfield(handles, 'message') && isvalid(handles.message)
            set(handles.message, 'string', 'Adjusting advanced adenoma by Nelder-Mead simplex search')
            drawnow
        end
        %%% the path were this program is stored, this must be the CMOST path
        Path = mfilename('fullpath');
        pos = regexp(Path, [mfilename, '$']);
        CurrentPath = Path(1:pos-1);
        cd (fullfile(CurrentPath, 'Temp'))
        save('Calibration_2_temp', 'Calibration_2_temp');
        
        % for the second optimization we use the fminsearch function
        % 设置迭代次数限制以确保能够停止
        % 注意：fminsearch 中 MaxIter 是迭代次数，MaxFunEvals 是函数评估次数
        % 对于 n 维问题，每次迭代约需 n+1 次函数评估
        n_params = 3; % 默认参数数量
        if and(handles.Flow.AdFlag, handles.Flow.DistFlag)
            n_params = 4;
        elseif handles.Flow.DistFlag
            n_params = 1;
        end
        max_fun_evals = handles.Flow.Number_second_iteration * (n_params + 2);
        
        options = optimset('OutputFcn', @Auto_Calib_2_OutFunction, ...
            'MaxFunEvals', max_fun_evals, ...
            'MaxIter',     handles.Flow.Number_second_iteration, ...
            'TolX',        1e-4, ...   % 放宽精度以便更快收敛
            'TolFun',      1e-4, ...   % 放宽精度以便更快收敛
            'Display',     'off');     % 关闭显示
        % 使用多起点重启的 Nelder-Mead 搜索以减少陷入局部最优的风险
        if and(handles.Flow.AdFlag, handles.Flow.DistFlag) % we optimize adv. adenoma + distribution
            base = [CoeffsAdv_Final(1), CoeffsAdv_Final(2), CoeffsAdv_Final(3), ProgressionCoefficient];
            tmpff = @(x)Auto_Calib_2_TempFunction(x(1), x(2), x(3), x(4));
        elseif handles.Flow.AdFlag % we optimize adv adenoma only
            base = [CoeffsAdv_Final(1), CoeffsAdv_Final(2), CoeffsAdv_Final(3)];
            tmpff = @(x)Auto_Calib_2_TempFunction(x(1), x(2), x(3));
        elseif handles.Flow.DistFlag
            base = ProgressionCoefficient;
            tmpff = @(x)Auto_Calib_2_TempFunction(x(1));
        end
        % 生成若干起点（包括小扰动与少数随机起点）
        n_restarts = min(6, max(1, ceil(handles.Flow.Number_second_iteration/5)));
        starts = cell(1, n_restarts);
        starts{1} = base;
        rng(0,'twister'); % 可重复性
        for r = 2:n_restarts
            if isvector(base)
                perturb = 1 + (rand(size(base)) - 0.5) * 0.2; % ±10% 轻微扰动
                starts{r} = base .* perturb;
            else
                starts{r} = base;
            end
        end
        bestOutput = [];
        bestVal = inf;
        for r = 1:length(starts)
            try
                [cand] = fminsearch(tmpff, starts{r}, options);
                val = tmpff(cand);
                if isfinite(val) && val < bestVal
                    bestVal = val;
                    bestOutput = cand;
                end
            catch ME
                fprintf('fminsearch restart %d failed: %s\n', r, ME.message);
                continue;
            end
        end
        if isempty(bestOutput)
            % 若所有尝试均失败，退回使用base
            output = base;
        else
            output = bestOutput;
        end
        % 对输出进行边界约束，防止参数向非生理范围漂移
        if handles.Flow.AdFlag
            % A, k, x0 对应索引 1:3
            A = output(1); k = output(2); x0 = output(3);
            A = min(max(A, 0.01), 50);
            k = min(max(k, -5), 5);
            x0 = min(max(x0, 0), 100);
            output(1:3) = [A k x0];
        end
        if handles.Flow.DistFlag
            % ProgressionCoefficient 限制在 [0.01, 10]
            P = output(end);
            P = min(max(P, 0.01), 10);
            output(end) = P;
        end
        
        
        if and(handles.Flow.AdFlag, handles.Flow.DistFlag)
            CoeffsAdv_Final(1:3) = output(1:3);
            ProgressionCoefficient = output(4);
        elseif handles.Flow.AdFlag
            CoeffsAdv_Final(1:3) = output(1:3);
        elseif handles.Flow.DistFlag
            ProgressionCoefficient = output(1);
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
    % 在临时副本上应用优化结果以避免修改全局变量（不影响 Step1/Step3）
    clear tmp1 
    tmp1{1} = CoeffsAdv_Final; 
    tempHandles = handles;
    if handles.Flow.AdFlag
        tempHandles = AdjustRates(tempHandles, tmp1, index_age, 1);
        tempHandles.Flow.CoeffsAdv = CoeffsAdv_Final;
        tempHandles.Variables.early_progression_female = FemFactorAdv(MinAll);
    end
    if handles.Flow.DistFlag
        tempHandles.Variables.Progression(5) = ProgressionCoefficient;
    end
    if isfield(handles, 'message') && isvalid(handles.message)
        set(handles.message, 'string', 'Re-running with optimized parameters (temporary)')
        drawnow
    end

    % 我们先做一次临时运行并计算BM与RMS
    [~, BM_temp] = CalculateSub(tempHandles);
    [RMSA_temp, RMSP_temp, ~, ~] = CalculateRMS(tempHandles, BM_temp, BMAdvx, BMAdvy, Benchmark_AdvAd_perc, RMSA, RMSP, i);

    % 如果有未全部变绿，则尝试按年龄段局部放大 early progression（最多迭代5次）
    % 目标：在不改变 handles.Variables 的情况下让全部 Advanced Adenoma 标记为 'green'
    max_adjust_iters = 5; success = false;
    for adj_iter = 1:max_adjust_iters
        % 检查输出标记是否全部为 green
        ov_flags = BM_temp.OutputFlags.AdvAdenoma_Ov;
        male_flags = BM_temp.OutputFlags.AdvAdenoma_Male;
        female_flags = BM_temp.OutputFlags.AdvAdenoma_Female;
        if all(strcmp(ov_flags, 'green')) && all(strcmp(male_flags, 'green')) && all(strcmp(female_flags, 'green'))
            success = true; break;
        end

        % 计算在可用年龄点上的中位比例（benchmark / model）用于缩放
        model_vals = BM_temp.OutputValues.AdvAdenoma_Ov(:)';
        bench_vals = handles.Variables.Benchmarks.AdvPolyp.Ov_perc(:)';
        idx = bench_vals > 0.5; % 有效点阈值（避免极小bench带来噪声）
        if sum(idx) < 3
            idx = bench_vals > 0.1; % 次优阈值
        end
        if sum(idx) == 0
            break; % 无有效点，跳出
        end
        ratios = bench_vals(idx)./model_vals(idx);
        r = median(ratios(isfinite(ratios) & ratios>0));
        % 限制缩放范围以防过度调整
        r = min(max(r, 0.85), 1.5);

        % 将缩放应用到临时副本的早期进展率（保持其它参数不变）
        tempHandles.Variables.EarlyProgressionRate = tempHandles.Variables.EarlyProgressionRate * r;
        % 重新插值到年尺度
        counter = 1;
        for x1=1:19
            step_val = (tempHandles.Variables.EarlyProgressionRate(x1+1) - tempHandles.Variables.EarlyProgressionRate(x1)) / 5;
            for x2 = 0:4
                tempHandles.Variables.EarlyProgression(counter) = tempHandles.Variables.EarlyProgressionRate(x1) + x2 * step_val;
                counter = counter + 1;
            end
        end
        tempHandles.Variables.EarlyProgression(counter : 150) = tempHandles.Variables.EarlyProgressionRate(end);

        % 重新运行模型并评估
        [~, BM_temp] = CalculateSub(tempHandles);
        [RMSA_temp, RMSP_temp, ~, ~] = CalculateRMS(tempHandles, BM_temp, BMAdvx, BMAdvy, Benchmark_AdvAd_perc, RMSA_temp, RMSP_temp, i);
    end

    % 保存 Step2 的最终结果到 Calibration.Step2 命名空间，不覆盖原始变量
    if ~isfield(handles.Variables, 'Calibration') || ~isstruct(handles.Variables.Calibration)
        handles.Variables.Calibration = struct();
    end
    handles.Variables.Calibration.Step2.CoeffsAdv = CoeffsAdv_Final;
    handles.Variables.Calibration.Step2.ProgressionCoefficient = ProgressionCoefficient;
    if handles.Flow.AdFlag
        handles.Variables.Calibration.Step2.EarlyProgressionRate = tempHandles.Variables.EarlyProgressionRate;
    end
    handles.Variables.Calibration.Step2.RMSA = RMSA_temp(i);
    handles.Variables.Calibration.Step2.RMSP = RMSP_temp(i);
    handles.Variables.Calibration.Step2.BM = BM_temp;
    handles.Variables.Calibration.Step2.SuccessAllGreen = success;

    % 更新 GUI 显示为临时计算的结果
    handles.Flow.RMSA = RMSA_temp;
    handles.Flow.RMSP = RMSP_temp;
    handles.Flow.Iteration = i;
    if handles.Flow.AdFlag
        handles.Flow.RMS_Adv_current     = RMSA_temp(i);
    end
    if handles.Flow.DistFlag
        handles.Flow.RMS_Ad_distr_current = RMSP_temp(i);
    end

    % 将 Calibration 保存到 VariablesBackup 以便持久化（即使恢复原始变量也保留Calibration）
    VariablesBackup.Calibration = handles.Variables.Calibration;
    % 恢复原始的 handles.Variables（保证 Step1/3 变量不被覆盖）
    handles.Variables = VariablesBackup;

    % 恢复 flags 并结束
    handles.Variables.DispFlag    = DispFlagBackup;
    handles.Variables.ResultsFlag = ResultsFlagBackup;
    handles.Variables.ExcelFlag   = ExcelFlagBackup;
    handles.Variables.Number_patients = NumberPatientsBackup; % 恢复原始模拟人数
    if success
        handles.Flow.Message = 'Optimization finished (Step2 saved — all green)';
    else
        handles.Flow.Message = 'Optimization finished (Step2 saved — some red remain)';
    end
else
    handles.Variables = VariablesBackup;
    handles = InitializeValues(handles);
end
if exist('BM_temp','var') && ~isempty(BM_temp)
    handles = MakeImagesCurrent(hObject, handles, BM_temp);
else
    handles = MakeImagesCurrent(hObject, handles, BM);
end %#ok<NASGU>
end

%%%% calculate RMS
function [RMSA, RMSP, BMAdvx, BMAdvy] = CalculateRMS(handles, BM, BMAdvx,...
    BMAdvy, Benchmark_AdvAd_perc, RMSA, RMSP, i)

% RMS for advanced adenoma - 综合考虑Overall/Male/Female
BMAdvx{i}   = 1/5*handles.Variables.Benchmarks.AdvPolyp.Ov_y; %corr BM
BMAdvy{i}   = BM.OutputValues.AdvAdenoma_Ov;

if handles.Flow.AdFlag
    % ===== 计算Overall RMS =====
    ageYears = handles.Variables.Benchmarks.AdvPolyp.Ov_y;
    benchPerc = Benchmark_AdvAd_perc(:)';
    
    % 平衡权重策略：温和强调低年龄段，避免过度拟合
    % 1. 相对误差权重：绝对值小→权重稍大（但不过度）
    relativeError_weights = 1 ./ (1 + 0.5 * benchPerc / max(benchPerc));  % 降低至0.5
    
    % 2. 年龄权重：平衡型配置
    ageWeights = ones(size(benchPerc));
    for k = 1:length(ageWeights)
        if ageYears(k) < 30
            ageWeights(k) = 1.5;   % 低年龄：权重加1.5倍（从2.5降至1.5）
        elseif ageYears(k) < 45
            ageWeights(k) = 1.3;   % 中低年龄：权重加1.3倍（从2.0降至1.3）
        elseif ageYears(k) < 60
            ageWeights(k) = 1.1;   % 中年龄：权重加1.1倍（从1.5降至1.1）
        elseif ageYears(k) < 70
            ageWeights(k) = 1.0;
        end
    end
    
    % 3. 综合权重
    weights_ov = relativeError_weights .* ageWeights;
    weights_ov = weights_ov / mean(weights_ov);  % 归一化
    
    RMS_Ov = 0;
    for j=1:length(benchPerc)
        if Benchmark_AdvAd_perc(j) > 1e-6
            relError = abs(BMAdvy{i}(j) - benchPerc(j)) / benchPerc(j);
            term = weights_ov(j) * relError^2;
            if isfinite(term)
                RMS_Ov = RMS_Ov + term;
            end
        end
    end
    RMS_Ov = sqrt(RMS_Ov / length(benchPerc));
    
    % ===== 计算Male RMS =====
    ageMale = handles.Variables.Benchmarks.AdvPolyp.Male_y;
    benchMale = handles.Variables.Benchmarks.AdvPolyp.Male_perc(:)';
    
    relError_weights_male = 1 ./ (1 + 0.5 * benchMale / max(benchMale));
    ageWeights_male = ones(size(benchMale));
    for k = 1:length(ageWeights_male)
        if ageMale(k) < 30
            ageWeights_male(k) = 1.5;
        elseif ageMale(k) < 45
            ageWeights_male(k) = 1.3;
        elseif ageMale(k) < 60
            ageWeights_male(k) = 1.1;
        elseif ageMale(k) < 70
            ageWeights_male(k) = 1.0;
        end
    end
    
    weights_male = relError_weights_male .* ageWeights_male;
    weights_male = weights_male / mean(weights_male);
    
    RMS_Male = 0;
    for j=1:length(benchMale)
        if benchMale(j) > 1e-6
            relError = abs(BM.OutputValues.AdvAdenoma_Male(j) - benchMale(j)) / benchMale(j);
            term = weights_male(j) * relError^2;
            if isfinite(term)
                RMS_Male = RMS_Male + term;
            end
        end
    end
    RMS_Male = sqrt(RMS_Male / length(benchMale));
    
    % ===== 计算Female RMS =====
    ageFemale = handles.Variables.Benchmarks.AdvPolyp.Female_y;
    benchFemale = handles.Variables.Benchmarks.AdvPolyp.Female_perc(:)';
    
    relError_weights_female = 1 ./ (1 + 0.5 * benchFemale / max(benchFemale));
    ageWeights_female = ones(size(benchFemale));
    for k = 1:length(ageWeights_female)
        if ageFemale(k) < 30
            ageWeights_female(k) = 1.5;
        elseif ageFemale(k) < 45
            ageWeights_female(k) = 1.3;
        elseif ageFemale(k) < 60
            ageWeights_female(k) = 1.1;
        elseif ageFemale(k) < 70
            ageWeights_female(k) = 1.0;
        end
    end
    
    weights_female = relError_weights_female .* ageWeights_female;
    weights_female = weights_female / mean(weights_female);
    
    RMS_Female = 0;
    for j=1:length(benchFemale)
        if benchFemale(j) > 1e-6
            relError = abs(BM.OutputValues.AdvAdenoma_Female(j) - benchFemale(j)) / benchFemale(j);
            term = weights_female(j) * relError^2;
            if isfinite(term)
                RMS_Female = RMS_Female + term;
            end
        end
    end
    RMS_Female = sqrt(RMS_Female / length(benchFemale));
    
    % ===== 综合RMS：低年龄段匹配质量最关键 =====
    % Overall权重60%, Male权重25%, Female权重15%
    RMSA(i) = 0.6 * RMS_Ov + 0.25 * RMS_Male + 0.15 * RMS_Female;
    
    if ~isfinite(RMSA(i))
        RMSA(i) = 1e6;
    end
else
    RMSA(i) = 0;
end

if handles.Flow.DistFlag
    % RMS for advanced adenoma distribution
    RMSP(i) = 0;
    for f=5:6
        if BM.BM_value_adv(f) > 1e-6
            term = ((BM.Polyp_adv(f) - BM.BM_value_adv(f))/BM.BM_value_adv(f))^2;
            if isfinite(term)
                RMSP(i) = RMSP(i) + term;
            end
        end
    end
    if ~isfinite(RMSP(i))
        RMSP(i) = 1e6;
    end
else
    RMSP(i) = 0;
end

end

% adjust rates
function handles = AdjustRates(handles, CoeffsAdv, index_age, i)
if handles.Flow.AdFlag
    % we adjust the early adenoma progression rates (移除 1.5x 乘数保持一致性)
    handles.Variables.EarlyProgressionRate = 0.04*CoeffsAdv{i}(1).*exp(-0.01*CoeffsAdv{i}(2)*( index_age - CoeffsAdv{i}(3) ).^2);
    % 限制进展率为合理范围
    handles.Variables.EarlyProgressionRate = min(max(handles.Variables.EarlyProgressionRate, 0), 1);
    counter = 1;
    for x1=1:19
        for x2=1:5
            val = (handles.Variables.EarlyProgressionRate(x1) * (5-x2) + handles.Variables.EarlyProgressionRate(x1+1) * (x2-1))/4;
            handles.Variables.EarlyProgression(counter) = min(max(val, 0), 1);
            counter = counter + 1;
        end
    end
    handles.Variables.EarlyProgression(counter : 150) = handles.Variables.EarlyProgressionRate(end);
    handles.Variables.EarlyProgression(counter : 150) = min(max(handles.Variables.EarlyProgression(counter : 150),0),1);
end

end

% DELETE
function figure1_DeleteFcn(hObject, eventdata, handles) %#ok<DEFNU,INUSL>
handles.Variables = handles.OldVariables;
guidata(hObject, handles)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 本地替代 nlinfit（无统计工具箱时使用 fminsearch）
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function beta = my_nlinfit(X, Y, model, beta0)
    opts = optimset('TolX',1e-6,'TolFun',1e-6,'MaxIter',5000,'MaxFunEvals',10000,'Display','off');
    cost = @(b) sum((Y - model(b, X)).^2);
    beta = fminsearch(cost, beta0, opts);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 多初值 sigmoid 拟合（针对低年龄段优化 - 综合O/M/F）
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function bestP = multiStartSigmoidFit(u, y, p0, i_sigmoid)
    ages = u * 5;
    yRow = y(:)';
    
    % 极端激进权重：非常强调低年龄段
    % 1. 相对误差权重
    relativeError_weights = 1 ./ (1 + 0.6 * yRow / max(yRow));  % 提高至0.6
    
    % 2. 年龄权重：平衡分配
    ageWeights = ones(size(yRow));
    for k = 1:length(ageWeights)
        if ages(k) < 25
            ageWeights(k) = 1.5;   % 低年龄：从3.0降至1.5
        elseif ages(k) < 40
            ageWeights(k) = 1.3;   % 中低年龄：从2.5降至1.3
        elseif ages(k) < 55
            ageWeights(k) = 1.1;   % 中年龄：从2.0降至1.1
        elseif ages(k) < 70
            ageWeights(k) = 1.0;   % 从1.3降至1.0
        end
    end
    
    weights = relativeError_weights .* ageWeights;
    weights = weights / mean(weights);
    
    % 扩展初值列表：更多候选，覆盖更广的参数空间（保守策略）
    p0_list = [
        p0;                    % 原始初值
        8 1 9;                 % 标准组合
        10 0.9 8;              % 适度
        7 1.1 10;              % 平衡
        9 0.8 7;               % 较陡
        12 0.7 12;             % 陡峭
        6 1.3 14;              % 缓和
        5 1.4 15;              % 缓和低龄
        7 1.2 12;              % 平衡
        8 1.0 10;              % 标准
    ];
    
    opts = optimset('TolX',1e-6,'TolFun',1e-6,'MaxIter',8000,'MaxFunEvals',20000,'Display','off');
    bestP = p0;
    bestErr = inf;
    
    for k = 1:size(p0_list, 1)
        p_init = p0_list(k, :);
        
        % 加权最小二乘
        try
            p = fminsearch(@(pp) sum(weights .* (yRow - i_sigmoid(pp, u)).^2), p_init, opts);
            err = sum(weights .* (yRow - i_sigmoid(p, u)).^2);
            
            if isfinite(err) && err < bestErr
                bestErr = err;
                bestP = p;
            end
        catch
            % 如果拟合失败，继续尝试其他初值
            continue;
        end
    end
end

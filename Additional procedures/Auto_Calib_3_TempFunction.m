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

function [RMS_output] = Auto_Calib_3_TempFunction(varargin) %, Coeff1, Coeff2, Coeff3, Coeff4, Coeff5)

C(1) = varargin{1};
C(2) = varargin{2};
C(3) = varargin{3};

index_age=1:20;

% 尽早确定当前路径并尝试加载临时状态（避免在边界检查中引用未定义变量）
Path = mfilename('fullpath');
pos = regexp(Path, [mfilename, '$']);
CurrentPath = Path(1:pos-1);

% 尝试从 Temp 文件夹加载已有的 Calibration_3_temp 状态
try
    tempFile = fullfile(CurrentPath, '../Storyboards', 'Temp', 'Calibration_3_temp.mat');
    if exist(tempFile, 'file')
        tmp = load(tempFile, 'Calibration_3_temp');
        if isfield(tmp, 'Calibration_3_temp')
            Calibration_3_temp = tmp.Calibration_3_temp;
        else
            Calibration_3_temp = struct();
        end
    else
        Calibration_3_temp = struct();
    end
catch ME_load
    warning('Could not load Calibration_3_temp: %s', ME_load.message);
    Calibration_3_temp = struct();
end

% 确保必要字段存在
if ~isfield(Calibration_3_temp, 'Flow') || ~isfield(Calibration_3_temp.Flow, 'Iteration')
    Calibration_3_temp.Flow.Iteration = 0;
end
if ~isfield(Calibration_3_temp.Flow, 'RMSI')
    Calibration_3_temp.Flow.RMSI = [];
end
if ~isfield(Calibration_3_temp.Flow, 'Debug')
    Calibration_3_temp.Flow.Debug = struct();
end
if ~isfield(Calibration_3_temp, 'Variables')
    Calibration_3_temp.Variables = struct();
end

% 参数边界检查：如果 fminsearch 试探出不合理参数，直接返回大惩罚，避免模型数值爆炸
% 合理范围（经验）：A in [50,400], B in (0,1], C in [30,80]
if C(1) < 50 || C(1) > 400 || C(2) <= 0 || C(2) > 1 || C(3) < 30 || C(3) > 80
    % 增加调试记录并保存状态（保底保存到 Temp）
    Calibration_3_temp.Flow.Iteration = Calibration_3_temp.Flow.Iteration + 1;
    Calibration_3_temp.Flow.RMSI = Calibration_3_temp.Flow.RMSI;
    if ~isfield(Calibration_3_temp.Flow, 'Debug'), Calibration_3_temp.Flow.Debug = struct(); end
    Calibration_3_temp.Flow.Debug.deltaBM(Calibration_3_temp.Flow.Iteration) = NaN;
    Calibration_3_temp.Flow.Debug.coeffs(Calibration_3_temp.Flow.Iteration, :) = C;
    try
        save(fullfile(CurrentPath, '../Storyboards', 'Temp', 'Calibration_3_temp.mat'), 'Calibration_3_temp');
    catch ME_save
        warning('Could not save Calibration_3_temp during bound check: %s', ME_save.message);
    end
    RMS_output = 1e6;
    return
end

%%% the path were this proggram is stored, this must be the CMOST path
Path = mfilename('fullpath');
pos = regexp(Path, [mfilename, '$']);
CurrentPath = Path(1:pos-1);
cd(fullfile(CurrentPath, '../Storyboards', 'Temp'))
load ('Calibration_3_temp');

handles.Variables = Calibration_3_temp.Variables; %#ok<NODEF>
Calibration_3_temp.Flow.Iteration = Calibration_3_temp.Flow.Iteration + 1;

i    = Calibration_3_temp.Flow.Iteration;
RMSI = Calibration_3_temp.Flow.RMSI;

% we adjust cancer incidence rates using improved model
% 🔄 改进的Logistic模型 + 高年龄衰减项
% 关键改进：添加高年龄段衰减因子以防止70岁以上过拟合
% 公式: Rate = base_scaling * A / (1 + exp(-B * (age - C))) * decay_factor
% decay_factor = 1 对于 age < age_decay_start
% decay_factor = exp(-decay_rate * (age - age_decay_start)^2) 对于 age >= age_decay_start

base_scaling = 2.78e-4;  % 统一为 AdjustRates 使用的缩放因子

age_values = index_age * 5;  % 转换为实际年龄 (5, 10, 15, ..., 100)

% 核心Logistic项
logistic_term = 1 ./ (1 + exp(-C(2) * (age_values - C(3))));

% 高年龄衰减项 - 对齐 AdjustRates 的温和衰减设置，保证 fminsearch 与 AdjustRates 使用相同映射
age_decay_start = 82;        % 延后衰减开始年龄
decay_rate = 0.00090;       % 温和衰减率
extra_decay_start = 96;     % 超高龄衰减开始年龄
extra_decay_rate = 0.0014;  % 温和超高龄衰减率

decay_factor = ones(size(age_values));
extra_decay_factor = ones(size(age_values));
for k = 1:length(age_values)
    if age_values(k) > age_decay_start
        % 使用高斯衰减函数
        decay_factor(k) = exp(-decay_rate * (age_values(k) - age_decay_start)^2);
    end
    if age_values(k) > extra_decay_start
        extra_decay_factor(k) = exp(-extra_decay_rate * (age_values(k) - extra_decay_start)^2);
    end
end

% 组合最终进展率
handles.Variables.AdvancedProgressionRate = base_scaling * C(1) * logistic_term .* decay_factor .* extra_decay_factor;

counter = 1;
for x1=1:19
    for x2=1:5
        handles.Variables.AdvancedProgression(counter) = (handles.Variables.AdvancedProgressionRate(x1) * (5-x2) + ...
            handles.Variables.AdvancedProgressionRate(x1+1) * (x2-1))/4;
        counter = counter + 1;
    end
end
handles.Variables.AdvancedProgression(counter : 150) = handles.Variables.AdvancedProgressionRate(end);
    
% the next run...
[~, BM]=CalculateSub(handles);

% 获取已有的 RMSD 和 RMSR 数组（如果存在）
if isfield(Calibration_3_temp.Flow, 'RMSD')
    RMSD = Calibration_3_temp.Flow.RMSD;
else
    RMSD = zeros(1, 200);
end
if isfield(Calibration_3_temp.Flow, 'RMSR')
    RMSR = Calibration_3_temp.Flow.RMSR;
else
    RMSR = zeros(1, 200);
end

% we calculate RMS for carcinoma incidence - 优化版本 v3
% 改进：增加高年龄段过拟合惩罚
% ===== Overall RMS =====
benchOv = handles.Variables.Benchmarks.Cancer.Ov_inc(:)';
ageOv = handles.Variables.Benchmarks.Cancer.Ov_y;

% 权重策略：相对误差权重 * 年龄权重
% 改进：对高年龄段（>70岁）过高估计增加额外惩罚
relError_weights_ov = 1 ./ (1 + 0.3 * benchOv / max(benchOv));
ageWeights_ov = ones(size(benchOv));
for k = 1:length(ageWeights_ov)
    if ageOv(k) < 45
        ageWeights_ov(k) = 2.0;
    elseif ageOv(k) < 60
        ageWeights_ov(k) = 1.5;
    elseif ageOv(k) < 70
        ageWeights_ov(k) = 1.2;
    elseif ageOv(k) < 80
        ageWeights_ov(k) = 1.5;  % 适度提升70-80岁权重
    else
        ageWeights_ov(k) = 2.0;  % 适度提升80岁以上权重
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
            
            % 额外惩罚：对高年龄段过高估计增加惩罚因子
            overestimate_penalty = 1.0;
            if ageOv(j) > 70 && calcVal > benchOv(j)
                overestimate_penalty = 1.4 + 0.02 * (ageOv(j) - 70);
            end
            
            term = weights_ov(j) * overestimate_penalty * relError^2;
            if isfinite(term)
                RMS_Ov = RMS_Ov + term;
            end
        end
    end
    RMS_Ov = sqrt(RMS_Ov / maxLen_Ov);
benchMale = handles.Variables.Benchmarks.Cancer.Male_inc(:)';
ageMale = handles.Variables.Benchmarks.Cancer.Male_y;

relError_weights_male = 1 ./ (1 + 0.3 * benchMale / max(benchMale));
ageWeights_male = ones(size(benchMale));
for k = 1:length(ageWeights_male)
    if ageMale(k) < 35
        ageWeights_male(k) = 1.5;  % 20-35岁中等权重
    elseif ageMale(k) < 60
        ageWeights_male(k) = 2.5;  % 35-60岁加强权重，重点拟合
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
benchFemale = handles.Variables.Benchmarks.Cancer.Female_inc(:)';
ageFemale = handles.Variables.Benchmarks.Cancer.Female_y;

relError_weights_female = 1 ./ (1 + 0.3 * benchFemale / max(benchFemale));
ageWeights_female = ones(size(benchFemale));
for k = 1:length(ageWeights_female)
    if ageFemale(k) < 45
        ageWeights_female(k) = 1.5;  % 年轻女性权重适中
    elseif ageFemale(k) < 60
        ageWeights_female(k) = 1.2;
    elseif ageFemale(k) < 75
        ageWeights_female(k) = 2.3;  % 60-75岁加强权重，重点拟合
    elseif ageFemale(k) < 85
        ageWeights_female(k) = 2.5;  % 75-85岁更加强权重
    else
        ageWeights_female(k) = 2.2;  % 85岁以上也加强
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
        % 惩罚Female 60-90岁的偏差（可能是过高或过低）
        overestimate_penalty = 1.0;
        if ageFemale(j) >= 60 && ageFemale(j) <= 90
            % Female 60-90岁所有误差都加权
            if calcVal > benchFemale(j)
                % 过高估计加重惩罚（适度增强）
                overestimate_penalty = 2.0 + 0.03 * (ageFemale(j) - 60);
            else
                % 过低估计也加权（保留一定拉升能力）
                overestimate_penalty = 1.6 + 0.02 * (ageFemale(j) - 60);
            end
        end
        term = weights_female(j) * overestimate_penalty * relError^2;
        if isfinite(term)
            RMS_Female = RMS_Female + term;
        end
    end
end
RMS_Female = sqrt(RMS_Female / maxLen_Female);

% Combined RMS - 按照txt Step 3.1，三个目标应相对独立优化
% 主要目标：Cancer incidence (RMSI)
% 副目标：Relative danger (RMSD) 和 Fraction rectum (RMSR)
RMSI(i) = 0.5 * RMS_Ov + 0.3 * RMS_Male + 0.2 * RMS_Female;

% Regularization: discourage extreme parameter changes and overfitting
reg = 0;
if isfield(Calibration_3_temp.Flow, 'CoeffsInc') && ~isempty(Calibration_3_temp.Flow.CoeffsInc)
    prior = Calibration_3_temp.Flow.CoeffsInc;
else
    prior = C; % fallback
end
% small penalties relative to typical parameter scales
lambdaA = 0.01; lambdaB = 0.01; lambdaC = 0.003;
reg = lambdaA * ((C(1) - prior(1))/max(abs(prior(1)),1))^2 + lambdaB * (C(2) - prior(2))^2 + lambdaC * ((C(3) - prior(3))/max(abs(prior(3)),1))^2;
RMSI(i) = RMSI(i) + reg;

% 计算 RMSD (relative danger) - 按txt步骤2，需独立优化
if isfield(Calibration_3_temp.Flow, 'RelDangerFlag') && Calibration_3_temp.Flow.RelDangerFlag
    RMSD(i) = 0;
    for f=1:5
        if f <= length(BM.CancerOriginValue) && f <= length(handles.Variables.Benchmarks.Rel_Danger)
            benchVal = handles.Variables.Benchmarks.Rel_Danger(f);
            calcVal = BM.CancerOriginValue(f);
            if isfinite(calcVal) && isfinite(benchVal) && abs(benchVal) > 1e-6
                RMSD(i) = RMSD(i) + (1 - calcVal/benchVal)^2;
            end
        end
    end
    RMSD(i) = sqrt(RMSD(i) / 5);
    if ~isfinite(RMSD(i)), RMSD(i) = 1e6; end
else
    RMSD(i) = 0;
end

% 计算 RMSR (fraction rectum) - 按txt步骤3，需独立优化
if isfield(Calibration_3_temp.Flow, 'AdjFractionRectumFlag') && Calibration_3_temp.Flow.AdjFractionRectumFlag
    RMSR(i) = 0;
    for f=2:3
        if f <= length(BM.LocBenchmark) && f <= length(BM.LocationRectum)
            benchVal = BM.LocBenchmark(f);
            calcVal = BM.LocationRectum(f);
            if isfinite(calcVal) && isfinite(benchVal) && abs(benchVal) > 1e-6
                RMSR(i) = RMSR(i) + ((calcVal - benchVal)/benchVal)^2;
            end
        end
    end
    RMSR(i) = sqrt(RMSR(i) / 2);
    if ~isfinite(RMSR(i)), RMSR(i) = 1e6; end
else
    RMSR(i) = 0;
end

% 仅关注Cancer incidence，不被relative danger或rectum约束
RMS_output = RMSI(i);

% compute change relative to previous BM (for debugging / detect no-change cases)
if isfield(Calibration_3_temp, 'BM') && isfield(Calibration_3_temp.BM, 'OutputValues') && isfield(BM, 'OutputValues')
    try
        prev = Calibration_3_temp.BM.OutputValues.Cancer_Ov;
        curr = BM.OutputValues.Cancer_Ov;
        deltaBM = norm(curr(1:min(length(prev), length(curr))) - prev(1:min(length(prev), length(curr))));
    catch
        deltaBM = NaN;
    end
else
    deltaBM = NaN;
end
Calibration_3_temp.BM        = BM;
Calibration_3_temp.Variables = handles.Variables;

Calibration_3_temp.Flow.Iteration = Calibration_3_temp.Flow.Iteration;
Calibration_3_temp.Flow.RMSI      = RMSI;
Calibration_3_temp.Flow.RMSD      = RMSD;
Calibration_3_temp.Flow.RMSR      = RMSR;
Calibration_3_temp.Flow.Debug.deltaBM(Calibration_3_temp.Flow.Iteration) = deltaBM; 
Calibration_3_temp.Flow.Debug.coeffs(Calibration_3_temp.Flow.Iteration, :) = C; 

cd(fullfile(CurrentPath, '../Storyboards', 'Temp'))
save('Calibration_3_temp', 'Calibration_3_temp')

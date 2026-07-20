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

function [RMS_output] = Auto_Calib_2_TempFunction(varargin) %, Coeff1, Coeff2, Coeff3, Coeff4, Coeff5)

if isequal(length(varargin), 1)
    P    = varargin{1};
elseif isequal(length(varargin), 3)
    B(1) = varargin{1};
    B(2) = varargin{2};
    B(3) = varargin{3};
elseif isequal(length(varargin), 4)
    B(1) = varargin{1};
    B(2) = varargin{2};
    B(3) = varargin{3};
    P    = varargin{4};
end
index_age=1:20;

%%% the path were this proggram is stored, this must be the CMOST path
Path = mfilename('fullpath');
pos = regexp(Path, [mfilename, '$']);
CurrentPath = Path(1:pos-1);
cd(fullfile(CurrentPath, '../Storyboards', 'Temp'))
load ('Calibration_2_temp');

handles.Variables = Calibration_2_temp.Variables; %#ok<NODEF>
Calibration_2_temp.Flow.Iteration = Calibration_2_temp.Flow.Iteration + 1;

i    = Calibration_2_temp.Flow.Iteration;
RMSA = Calibration_2_temp.Flow.RMSA;
RMSP = Calibration_2_temp.Flow.RMSP;

if and(Calibration_2_temp.Flow.AdFlag, Calibration_2_temp.Flow.DistFlag)
    Mod = 'Both';
elseif Calibration_2_temp.Flow.AdFlag
    Mod = 'Ad';
elseif Calibration_2_temp.Flow.DistFlag
    Mod = 'Dist';
end

if or(isequal(Mod, 'Ad'), isequal(Mod, 'Both'))
    % we adjust the early adenoma progression rate according to the sigmoid function
    % 移除 1.5x 乘数保持与主校准脚本一致
    handles.Variables.EarlyProgressionRate = 0.04*B(1).*exp(-0.01*B(2)*( index_age - B(3) ).^2);
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


if or(isequal(Mod, 'Dist'), isequal(Mod, 'Both'))
    handles.Variables.Progression(5) = P;
end
    
% the next run...
[~, BM]=CalculateSub(handles);

BMAdvy = BM.OutputValues.AdvAdenoma_Ov;

if or(isequal(Mod, 'Ad'), isequal(Mod, 'Both'))
    % 计算Advanced Adenoma RMS，使用激进的权重策略
    % ===== Overall RMS =====
    benchOv = handles.Variables.Benchmarks.AdvPolyp.Ov_perc(:)';
    ageOv = handles.Variables.Benchmarks.AdvPolyp.Ov_y;
    
    relError_weights_ov = 1 ./ (1 + 0.3 * benchOv / max(benchOv));
    ageWeights_ov = ones(size(benchOv));
    for k = 1:length(ageWeights_ov)
        if ageOv(k) < 30
            ageWeights_ov(k) = 2.5;
        elseif ageOv(k) < 45
            ageWeights_ov(k) = 2.0;
        elseif ageOv(k) < 60
            ageWeights_ov(k) = 1.5;
        elseif ageOv(k) < 70
            ageWeights_ov(k) = 1.2;
        end
    end
    weights_ov = relError_weights_ov .* ageWeights_ov;
    weights_ov = weights_ov / mean(weights_ov);
    
    RMS_Ov = 0;
    for j=1:length(benchOv)
        if benchOv(j) > 1e-6
            relError = abs(BMAdvy(j) - benchOv(j)) / benchOv(j);
            term = weights_ov(j) * relError^2;
            if isfinite(term)
                RMS_Ov = RMS_Ov + term;
            end
        end
    end
    RMS_Ov = sqrt(RMS_Ov / length(benchOv));
    
    % ===== Male RMS =====
    benchMale = handles.Variables.Benchmarks.AdvPolyp.Male_perc(:)';
    ageMale = handles.Variables.Benchmarks.AdvPolyp.Male_y;
    
    relError_weights_male = 1 ./ (1 + 0.3 * benchMale / max(benchMale));
    ageWeights_male = ones(size(benchMale));
    for k = 1:length(ageWeights_male)
        if ageMale(k) < 30
            ageWeights_male(k) = 2.5;
        elseif ageMale(k) < 45
            ageWeights_male(k) = 2.0;
        elseif ageMale(k) < 60
            ageWeights_male(k) = 1.5;
        elseif ageMale(k) < 70
            ageWeights_male(k) = 1.2;
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
    
    % ===== Female RMS =====
    benchFemale = handles.Variables.Benchmarks.AdvPolyp.Female_perc(:)';
    ageFemale = handles.Variables.Benchmarks.AdvPolyp.Female_y;
    
    relError_weights_female = 1 ./ (1 + 0.3 * benchFemale / max(benchFemale));
    ageWeights_female = ones(size(benchFemale));
    for k = 1:length(ageWeights_female)
        if ageFemale(k) < 30
            ageWeights_female(k) = 2.5;
        elseif ageFemale(k) < 45
            ageWeights_female(k) = 2.0;
        elseif ageFemale(k) < 60
            ageWeights_female(k) = 1.5;
        elseif ageFemale(k) < 70
            ageWeights_female(k) = 1.2;
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
    
    % 综合RMS
    RMSA(i) = 0.6 * RMS_Ov + 0.25 * RMS_Male + 0.15 * RMS_Female;
    RMS_output = RMSA(i);
else
    RMS_output = 0;
end

if or(isequal(Mod, 'Dist'), isequal(Mod, 'Both'))
    RMSP(i) = 0;
    for f=5:6
        % 添加数值检查防止除零
        if BM.BM_value_adv(f) > 1e-6
            RMSP(i) = RMSP(i) + ((BM.Polyp_adv(f) - BM.BM_value_adv(f))/BM.BM_value_adv(f))^2;
        end
    end
    RMS_output = RMS_output + RMSP(i);
end

% 对参数偏离先验添加轻微正则化惩罚（如果先验存在）
penalty = 0;
if isfield(Calibration_2_temp, 'PriorLambda') && Calibration_2_temp.PriorLambda > 0
    lambda = Calibration_2_temp.PriorLambda;
    if exist('B', 'var') && isfield(Calibration_2_temp, 'PriorCoeffs')
        priorB = Calibration_2_temp.PriorCoeffs;
        % 使用相对偏差平方
        rel = (B(:) - priorB(:))./max(abs(priorB(:)), 1e-6);
        penalty = penalty + lambda * sum(rel.^2);
    end
    if exist('P', 'var') && isfield(Calibration_2_temp, 'PriorProgression')
        priorP = Calibration_2_temp.PriorProgression;
        penalty = penalty + lambda * ((P - priorP).^2) / max(priorP^2, 1e-6);
    end
    RMS_output = RMS_output + penalty;
end

% 最终检查：如果 RMS 是 NaN 或 Inf，返回一个大的惩罚值
if ~isfinite(RMS_output)
    RMS_output = 1e6;
end

% 只有在 P 存在时才保存
if exist('P', 'var')
    Calibration_2_temp.P(i) = P;
end
Calibration_2_temp.BM        = BM;
Calibration_2_temp.Variables = handles.Variables;

Calibration_2_temp.Flow.Iteration = Calibration_2_temp.Flow.Iteration;
Calibration_2_temp.Flow.RMSA      = RMSA;
Calibration_2_temp.Flow.RMSP      = RMSP;
cd(fullfile(CurrentPath, '../Storyboards', 'Temp'))
save('Calibration_2_temp', 'Calibration_2_temp')


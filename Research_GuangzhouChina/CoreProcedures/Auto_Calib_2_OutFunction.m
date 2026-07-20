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

function stop = Auto_Calib_2_OutFunction(varargin)

%%% the path were this proggram is stored, this must be the CMOST path
Path = mfilename('fullpath');
pos = regexp(Path, [mfilename, '$']);
CurrentPath = Path(1:pos-1);
cd (fullfile(CurrentPath, '../Storyboards', 'Temp'))
load ('Calibration_2_temp');

handles.Variables = Calibration_2_temp.Variables;
handles.Flow      = Calibration_2_temp.Flow;
BM                = Calibration_2_temp.BM;

FontSz   = 10;
MarkerSz = 5;
LineSz   = 0.4;
a=findall(0);

stop = false;

% 检查是否达到最大迭代次数（作为安全措施）
max_iter = handles.Flow.Number_second_iteration;
if isfield(handles.Flow, 'Phase2_MaxIter')
    max_iter = handles.Flow.Phase2_MaxIter;
end

if handles.Flow.Iteration >= max_iter
    stop = true;
    fprintf('第二阶段达到最大迭代次数 %d，自动停止\n', max_iter);
end

c=findobj(a, 'tag', 'Iteration_number');
set(c, 'string', num2str(handles.Flow.Iteration))

c=findobj(a, 'tag', 'RMS_AdvAd_current');  
set(c, 'string', num2str(handles.Flow.RMSA(end)))

c=findobj(a, 'tag', 'RMS_distribution_current');
set(c, 'string', num2str(handles.Flow.RMSP(end)))


% adjust advanced adenoma graphs
% overall
MakeGraphik(BM.Graph.AdvAdenoma_Ov, handles.Variables.Benchmarks.AdvPolyp.Ov_y,...
    handles.Variables.Benchmarks.AdvPolyp.Ov_perc, BM.OutputValues.AdvAdenoma_Ov,...
    BM.OutputFlags.AdvAdenoma_Ov, 'Prevalence adenoma overall', 'percent of patients', LineSz, MarkerSz, FontSz, 'Ad', a)

% male
MakeGraphik(BM.Graph.AdvAdenoma_Male, handles.Variables.Benchmarks.AdvPolyp.Male_y,...
    handles.Variables.Benchmarks.AdvPolyp.Male_perc, BM.OutputValues.AdvAdenoma_Male,...
    BM.OutputFlags.AdvAdenoma_Male, 'Prevalence adenoma male', 'percent of patients', LineSz, MarkerSz, FontSz, 'Ad', a)

% female
MakeGraphik(BM.Graph.AdvAdenoma_Female, handles.Variables.Benchmarks.AdvPolyp.Female_y,...
    handles.Variables.Benchmarks.AdvPolyp.Female_perc, BM.OutputValues.AdvAdenoma_Female,...
    BM.OutputFlags.AdvAdenoma_Female, 'Prevalence adenoma female', 'percent of patients', LineSz, MarkerSz, FontSz, 'Ad', a)

% distribution of adenoma stages
b=findobj(a, 'string', 'distribution of P5/ P6 adenoma stages');
if ~isempty(b)
    parentObj = get(b(1), 'Parent');
    if isgraphics(parentObj, 'axes')
        % 使用 set 而不是 axes 以避免窗口弹出
        fig = ancestor(parentObj, 'figure');
        if ~isempty(fig), set(fig, 'CurrentAxes', parentObj); end
        cla(parentObj)
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
    end
end

% Adjusting RMS Graph advanced
b=findobj(a, 'string', 'RMS adv. ad. prevalence');
if ~isempty(b)
    parentObj = get(b(1), 'Parent');
    if isgraphics(parentObj, 'axes')
        % 使用 set 而不是 axes 以避免窗口弹出
        fig = ancestor(parentObj, 'figure');
        if ~isempty(fig), set(fig, 'CurrentAxes', parentObj); end
        cla(parentObj)
        % 只绘制有效的迭代次数
        valid_idx = find(handles.Flow.RMSA ~= 0, 1, 'last');
        if isempty(valid_idx), valid_idx = 1; end
        plot(1:valid_idx, handles.Flow.RMSA(1:valid_idx)), hold on
        for f=1:valid_idx
            plot(f, handles.Flow.RMSA(f), '--rs','LineWidth',1, 'MarkerEdgeColor','k', 'MarkerFaceColor','g', 'MarkerSize',3)
        end
        title('RMS adv. ad. prevalence')
        set(gca, 'color',  [0.6 0.6 1], 'box', 'off')
    end
end

% Adjusting adenoma distribution
b=findobj(a, 'string', 'RMS ad. stage distribution');
if ~isempty(b)
    parentObj = get(b(1), 'Parent');
    if isgraphics(parentObj, 'axes')
        % 使用 set 而不是 axes 以避免窗口弹出
        fig = ancestor(parentObj, 'figure');
        if ~isempty(fig), set(fig, 'CurrentAxes', parentObj); end
        cla(parentObj)
        % 只绘制有效的迭代次数
        valid_idx = find(handles.Flow.RMSP ~= 0, 1, 'last');
        if isempty(valid_idx), valid_idx = 1; end
        plot(1:valid_idx, handles.Flow.RMSP(1:valid_idx)), hold on
        for f=1:valid_idx
            plot(f, handles.Flow.RMSP(f), '--rs','LineWidth',1, 'MarkerEdgeColor','k', 'MarkerFaceColor','g', 'MarkerSize',3)
        end
        title('RMS ad. stage distribution')
        set(gca, 'color',  [0.6 0.6 1], 'box', 'off')
    end
end
drawnow  % 改为 drawnow（不加limitrate nocallbacks），以便处理Stop按钮点击事件

c=findobj(a, 'tag', 'Stop');  
d=get(c, 'enable');
if ~isempty(d) && ((iscell(d) && isequal(d{1}, 'off')) || (ischar(d) && isequal(d, 'off')))
       choice = questdlg('Are you sure you want to quit?',...
           'Quitting optimization?','yes', 'no', 'no'); 
       switch choice
           case    'yes'
               stop = true;
           case    'no'
               stop = false;
       end
end

function MakeGraphik(DataGraph, BM_year, BM_value, BM_current, BM_flags, GraphTitle, LabelY, LineSz, MarkerSz, FontSz, Mod, a)
b=findobj(a, 'string', GraphTitle);
if isempty(b)
    return; % 如果找不到对象，直接返回
end
% 获取父对象（坐标轴）
parentObj = [];
for idx = 1:numel(b)
    p = get(b(idx), 'Parent');
    if ~isempty(p) && isgraphics(p, 'axes')
        parentObj = p;
        break;
    end
end
if isempty(parentObj)
    return; % 如果找不到有效坐标轴，直接返回
end
% 使用 set 而不是 axes 以避免窗口弹出
fig = ancestor(parentObj, 'figure');
if ~isempty(fig), set(fig, 'CurrentAxes', parentObj); end
cla(parentObj)
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
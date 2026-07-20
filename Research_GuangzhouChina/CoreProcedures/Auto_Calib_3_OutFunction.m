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

function stop = Auto_Calib_3_OutFunction(varargin)

%%% the path were this proggram is stored, this must be the CMOST path
Path = mfilename('fullpath');
pos = regexp(Path, [mfilename, '$']);
CurrentPath = Path(1:pos-1);
cd (fullfile(CurrentPath, '../Storyboards', 'Temp'))
load ('Calibration_3_temp');

handles.Variables = Calibration_3_temp.Variables;
handles.Flow      = Calibration_3_temp.Flow;
BM                = Calibration_3_temp.BM;

FontSz   = 10;
MarkerSz = 5;
LineSz   = 0.4;
a=findall(0);

stop = false;

c=findobj(a, 'tag', 'Iteration_number');
set(c, 'string', num2str(handles.Flow.Iteration))
% show simple debug info if available
msgObj = findobj(a, 'tag', 'message');
if ~isempty(msgObj) && isfield(handles.Flow, 'Debug') && isfield(handles.Flow.Debug, 'deltaBM')
    idx = handles.Flow.Iteration;
    if idx <= length(handles.Flow.Debug.deltaBM)
        delta = handles.Flow.Debug.deltaBM(idx);
        try
            set(msgObj, 'string', sprintf('Iter %d — ΔBM=%.3g', handles.Flow.Iteration, delta));
        catch
            % ignore UI errors
        end
    end
end

c=findobj(a, 'tag', 'RMS_Ca_current');
set(c, 'string', num2str(handles.Flow.RMSI(end)))

c=findobj(a, 'tag', 'RMS_rel_danger_current');
set(c, 'string', num2str(handles.Flow.RMSD(end)))

c=findobj(a, 'tag', 'RMS_Fraction_Rectum_current');
set(c, 'string', num2str(handles.Flow.RMSR(end)))

% adjust Carcinoma graphs     
% overall
MakeGraphik(BM.Graph.Cancer_Ov, handles.Variables.Benchmarks.Cancer.Ov_y,...
    handles.Variables.Benchmarks.Cancer.Ov_inc, BM.OutputValues.Cancer_Ov,...
    BM.OutputFlags.Cancer_Ov, 'Incidence carcinoma overall', 'per 100''000 per year', LineSz, MarkerSz, FontSz, 'Ca', a)

% male
MakeGraphik(BM.Graph.Cancer_Male, handles.Variables.Benchmarks.Cancer.Male_y,...
    handles.Variables.Benchmarks.Cancer.Male_inc, BM.OutputValues.Cancer_Male,...
    BM.OutputFlags.Cancer_Male, 'Incidence carcinoma male', 'per 100''000 per year', LineSz, MarkerSz, FontSz, 'Ca', a)

% female
MakeGraphik(BM.Graph.Cancer_Female, handles.Variables.Benchmarks.Cancer.Female_y,...
    handles.Variables.Benchmarks.Cancer.Female_inc, BM.OutputValues.Cancer_Female,...
    BM.OutputFlags.Cancer_Female, 'Incidence carcinoma female', 'per 100''000 per year', LineSz, MarkerSz, FontSz, 'Ca', a)

% relative danger adenoma 
b=findobj(a, 'string', 'origin of cancer');
if ~isempty(b) && all(isvalid(b))
    if isprop(b, 'Parent') && all(isvalid(b.Parent)) && strcmp(get(b.Parent, 'type'), 'axes')
        % 使用 set 而不是 axes 以避免窗口弹出
        fig = ancestor(b.Parent, 'figure');
        if ~isempty(fig), set(fig, 'CurrentAxes', b.Parent); end
        cla(b.Parent);
    else
        ax = ancestor(b, 'axes');
        if ~isempty(ax) && all(isvalid(ax))
            fig = ancestor(ax, 'figure');
            if ~isempty(fig), set(fig, 'CurrentAxes', ax); end
            cla(ax);
        end
    end
end
area(BM.CancerOriginArea), grid on, colormap summer, set(gca,'Layer','top')
ylabel('% of all cancer', 'fontsize', FontSz), xlabel('decade', 'fontsize', FontSz)
title('origin of cancer', 'fontsize', FontSz)
set(gca, 'xlim', [0 10], 'ylim', [0 100], 'fontsize', FontSz)
cm = colormap; %#ok<NASGU>
cpos = [1  13 26 38 51 64]; %#ok<NASGU> % these are the positions in the colormap used for the graphs
for f=1:5
    %    line ([0.1 4], [BM.CancerOriginSummary(f) BM.CancerOriginSummary(f)], 'color', cm(cpos(f), :))
end
l=legend('Adenoma 3mm', 'Adenoma 5mm', 'Adenoma 7mm', 'Adenoma 9mm', 'Adv Ad P5', 'Adv Ad P6', 'direct');
set(l, 'location', 'northoutside', 'fontsize', FontSz)
ypos = 0;
for f=1:6
    line([1.5 2.5], [(ypos + BM.CancerOriginValue(f)/2) (ypos + BM.CancerOriginValue(f)/2)],...
        'color', BM.CancerOriginFlag{f})
    ypos = ypos + BM.CancerOriginValue(f);
end

% fraction rectum
b=findobj(a, 'string', 'fraction rectum carcinoma');
if ~isempty(b) && all(isvalid(b))
    if isprop(b, 'Parent') && all(isvalid(b.Parent)) && strcmp(get(b.Parent, 'type'), 'axes')
        % 使用 set 而不是 axes 以避免窗口弹出
        fig = ancestor(b.Parent, 'figure');
        if ~isempty(fig), set(fig, 'CurrentAxes', b.Parent); end
        cla(b.Parent);
    else
        ax = ancestor(b, 'axes');
        if ~isempty(ax) && all(isvalid(ax))
            fig = ancestor(ax, 'figure');
            if ~isempty(fig), set(fig, 'CurrentAxes', ax); end
            cla(ax);
        end
    end
end
plot(0:99, BM.LocationRectumAllGender(1:100)./ (BM.LocationRectumAllGender(1:100) + BM.LocationRest(1:100))*100, 'color', 'k'), hold on
for f=1:length(BM.LocX)
    x(f) = mean(BM.LocX{f}(1):BM.LocX{f}(2)); %#ok<AGROW>
    line(BM.LocX{f}, [BM.LocationRectum(f) BM.LocationRectum(f)], 'color', BM.LocationRectumFlag{f})
    plot(x(f), BM.LocationRectum(f), '--rs','LineWidth',LineSz, 'MarkerEdgeColor','k',...
        'MarkerFaceColor', BM.LocationRectumFlag{f}, 'MarkerSize',MarkerSz)
end
plot(x, BM.LocationRectum, '--rs','LineWidth',LineSz, 'MarkerEdgeColor','k', 'MarkerFaceColor','g', 'MarkerSize',MarkerSz)
plot(x, BM.LocBenchmark, '--bs','LineWidth',LineSz, 'MarkerEdgeColor','k', 'MarkerFaceColor','b', 'MarkerSize',MarkerSz)
xlabel('year', 'fontsize', FontSz), ylabel('% rectum of all ca', 'fontsize', FontSz)
set(gca, 'fontsize', FontSz), title('fraction rectum carcinoma', 'fontsize', FontSz)

% Adjusting RMS Graph carcinoma
b=findobj(a, 'string', 'RMS carcinoma incidence');
if ~isempty(b) && all(isvalid(b))
    if isprop(b, 'Parent') && all(isvalid(b.Parent)) && strcmp(get(b.Parent, 'type'), 'axes')
        % 使用 set 而不是 axes 以避免窗口弹出
        fig = ancestor(b.Parent, 'figure');
        if ~isempty(fig), set(fig, 'CurrentAxes', b.Parent); end
        cla(b.Parent);
    else
        ax = ancestor(b, 'axes');
        if ~isempty(ax) && all(isvalid(ax))
            fig = ancestor(ax, 'figure');
            if ~isempty(fig), set(fig, 'CurrentAxes', ax); end
            cla(ax);
        end
    end
end
% 只绘制有效的迭代次数
valid_idx = find(handles.Flow.RMSI ~= 0, 1, 'last');
if isempty(valid_idx), valid_idx = 1; end
plot(1:valid_idx, handles.Flow.RMSI(1:valid_idx)), hold on
for f=1:valid_idx
    plot(f, handles.Flow.RMSI(f), '--rs','LineWidth',1, 'MarkerEdgeColor','k', 'MarkerFaceColor','g', 'MarkerSize',3)
end 
title('RMS carcinoma incidence')
set(gca, 'color',  [0.6 0.6 1], 'box', 'off')
drawnow limitrate nocallbacks

c=findobj(a, 'tag', 'Stop_Cal3');
if ~isempty(c)
    d=get(c, 'enable');
    % 如果 Stop 按钮被禁用（已按下），则立即请求停止 fminsearch（不弹出对话）
    if isequal(d, 'off')
        stop = true;
    end
end

function MakeGraphik(DataGraph, BM_year, BM_value, BM_current, BM_flags, GraphTitle, LabelY, LineSz, MarkerSz, FontSz, Mod, a)
b=findobj(a, 'string', GraphTitle);
if ~isempty(b) && all(isvalid(b))
    if isprop(b, 'Parent') && all(isvalid(b.Parent)) && strcmp(get(b.Parent, 'type'), 'axes')
        % 使用 set 而不是 axes 以避免窗口弹出
        fig = ancestor(b.Parent, 'figure');
        if ~isempty(fig), set(fig, 'CurrentAxes', b.Parent); end
        cla(b.Parent);
    else
        ax = ancestor(b, 'axes');
        if ~isempty(ax) && all(isvalid(ax))
            fig = ancestor(ax, 'figure');
            if ~isempty(fig), set(fig, 'CurrentAxes', ax); end
            cla(ax);
        else
            return;
        end
    end
else
    return;
end
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
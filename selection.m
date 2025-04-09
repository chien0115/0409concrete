function [YY1, YY2, best_dispatch_times] = selection(P, F, s, dispatch_times)
    [x, y] = size(P); 
    YY1 = zeros(s, y); % 储存良好的染色体
    YY2 = zeros(s, 1); % 良好的适应值
    best_dispatch_times = zeros(s, size(dispatch_times, 2)); % Store dispatch times
    %zeros(s, size(dispatch_times, 2))的2代表dispatch_times的列數
    %EX:dispatch_times 的大小是 [100, 5] 則 best_dispatch_times = zeros(50, 5)

    e = min(round(s / 2), x); % Number of elite chromosomes to select, 确保不超过现有染色体数量
    %min(round(s / 2), x)取round(s / 2)和x中最小的值


    %E暫時適存值 L:在現有族群中最大之F值 F:染色體之真實適存值

    
    % Elite selection
    for i = 1:e
        c1 = find(F == min(F), 1); % Find index of the best fitness value
        
        % Store selected chromosome, fitness value, and dispatch times
        YY1(i, :) = P(c1, :);
        YY2(i) = F(c1);
        best_dispatch_times(i, :) = dispatch_times(c1, :);
        
        % Remove selected chromosome from population
        P(c1, :) = [];
        F(c1) = [];
        dispatch_times(c1, :) = [];
        
        % 更新维度 這行是在更新族群 P 的大小 因為每次選出精英後都會從 P 中移除這個染色體
        [x, ~] = size(P);
        
        % 确保在选择过程中不超出染色体数量
        if x == 0
            break;
        end
    end
    
    % 如果精英选择已经选够了所需的染色体，直接返回
    if e >= s
        YY1 = YY1(1:s, :);
        YY2 = YY2(1:s);
        best_dispatch_times = best_dispatch_times(1:s, :);
        return;
    end
    
    % Selection based on fitness probabilities for remaining chromosomes
    % s：需要的總染色體數量 e：已經通過精英選擇選出的數量  remaining：還需要選擇的染色體數量
    remaining = s - e;
    if x > 0 && remaining > 0
        D = F / sum(F); % Fitness proportionate selection
        CP = cumsum(D); % Cumulative probabilities
        
        %輪盤選擇過程：
        for i = 1:remaining
            N = rand(1); % Random number for selection  例如 N = 0.45： CP = [0.17, 0.50, 1.00] 找到第一個大於0.45的CP值 idx = 2（因為0.50 > 0.45）
            idx = find(CP >= N, 1);
            if isempty(idx)
                idx = length(CP); % 如果没有找到合适的索引，选择最后一个
            end
            
            YY1(e+i, :) = P(idx, :); %儲存染色體
            YY2(e+i) = F(idx);  %儲存適應值
            best_dispatch_times(e+i, :) = dispatch_times(idx, :); %儲存派遣時間
        end
    end
    
    % 如果选择的染色体数量不足，用原始人口中的染色体随机填充  
    % s = 100（需要100個染色體），原始P只有80個染色體，精英選擇選了40個，輪盤選擇也只能從剩下的40個中選，可能無法選足剩下的60個
    if size(YY1, 1) < s %預設選的數量比原陣列還多
        remaining = s - size(YY1, 1);
        original_indices = randperm(size(P, 1), remaining);  %randperm: 生成隨機排列的索引  從size(P, 1)選擇remaining個 都不同位置
        YY1(end+1:s, :) = P(original_indices, :);
        YY2(end+1:s) = F(original_indices);
        best_dispatch_times(end+1:s, :) = dispatch_times(original_indices, :);
    end
end
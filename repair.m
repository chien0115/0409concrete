function repaired_chromosome = repair(chromosome, demand_trips)
num_sites = length(demand_trips);
site_counts = zeros(1, num_sites);%矩陣為工地數量

% 計算當前訪問次數 看每個工地目前派遣幾次
for i = 1:num_sites
    site_counts(i) = sum(chromosome == i);
end

% 修復過多派遣次數的工地 出現次數大於所需
for site = 1:num_sites %派遣順序
    %site_counts 維度為工地數量 demand_trips為每個估地需要幾個派遣次數
    diff = site_counts(site) - demand_trips(site); %多出來的次數

    while diff > 0 %代表派遣次數過多
        % 找到需求不足的工地（按差異排序）
        shortages = demand_trips - site_counts; %EX:[2, 0, 3, -1]
        [sorted_shortages, shortage_idx] = sort(shortages, 'descend');%將短缺量由大到小排序
        %  EX:sorted_shortages = [3, 2, 0, -1]  shortage_idx = [3, 1, 2, 4]
        under_demand_sites = shortage_idx(sorted_shortages > 0); %找出所有短缺量大於 0 的工地索引 under_demand_sites = [3, 1]

        if isempty(under_demand_sites)
            break;
        end

        % 選擇最需要補充的工地
        new_site = under_demand_sites(1);

        % 找到最佳替換位置（考慮相鄰工地） 找出可替換的位置 是 for site因為需求次數過多 選出可以替換掉的位置
        site_positions = find(chromosome == site); %chromosome = [1,2,3,2,1] 且 site = 2, 則 site_positions 會是 [2,4]
        best_pos = find_best_position(chromosome, site_positions, new_site); %會在site_positions找一個改成其他

        if ~isempty(best_pos) % 如果找到了合適的替換位置
            chromosome(best_pos) = new_site;
            site_counts(new_site) = site_counts(new_site) + 1;
            site_counts(site) = site_counts(site) - 1;
            diff = diff - 1; % 過多的派遣次數減1
        else
            break;
        end
    end
end

% 檢查並修復未滿足需求的工地
while any(site_counts ~= demand_trips) %對應位置的值是否不相等
    shortages = demand_trips - site_counts;
    %找出最需要增加和減少的工地:
    [~, site_to_add] = max(shortages); %找出對應的位置
    excesses = site_counts - demand_trips;
    [~, site_to_remove] = max(excesses); % 找出多餘最多的工地


    % 如果最大缺少量≤0 或 最大多餘量≤0,表示沒有需要調整的了
    if shortages(site_to_add) <= 0 || excesses(site_to_remove) <= 0
        break;
    end

    % 尋找最佳交換位置
    positions_to_change = find(chromosome == site_to_remove);
    best_pos = positions_to_change(1);

    chromosome(best_pos) = site_to_add;
    site_counts(site_to_add) = site_counts(site_to_add) + 1;
    site_counts(site_to_remove) = site_counts(site_to_remove) - 1;
end

repaired_chromosome = chromosome;
end



%要檢查插入的位置左右跟要插入得工地有無一樣
function best_pos = find_best_position(chromosome, positions, new_site)
% positions: 可以替換的位置清單 new_site: 要插入的新工地編號
if isempty(positions)
    best_pos = [];
    return;
end

best_pos = positions(1);
min_conflicts = inf;

for pos = positions
    % 檢查相鄰位置的衝突
    conflicts = 0;
    if pos > 1 && chromosome(pos-1) == new_site
        conflicts = conflicts + 1;
    end
    if pos < length(chromosome) && chromosome(pos+1) == new_site
        conflicts = conflicts + 1;
    end

    if conflicts < min_conflicts
        min_conflicts = conflicts;
        best_pos = pos;
    end
end
end
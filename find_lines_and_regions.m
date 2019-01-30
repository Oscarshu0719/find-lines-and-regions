%% Part 00 - Pre-treatment.
clear; clc;

if ~exist('Result_Exp06', 'dir')
    mkdir('Result_Exp06');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Part 01 - Read image
READ_FOLDER = '';
disp('Please input the name of image.');
disp("Notice: Must use `'`.");
disp("For example the name of image is Lena.png, then you should input 'Lena.png'.");
IMG_PATH = input('Name = ');
IMG_NAME = IMG_PATH(1: (strfind(IMG_PATH, '.') - 1));
IMG_TYPE = IMG_PATH(strfind(IMG_PATH, '.'): length(IMG_PATH));
img = imread(strcat(READ_FOLDER, IMG_PATH));
IMG_SIZE = size(img);

if numel(size(img)) > 2
    img_gray = rgb2gray(img);
else
    img_gray = img;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Part 02 - Find top 3 longest lines with built-in functions.
% Use `Canny` operator to extract edges.
img_edge = edge(img_gray, 'canny');
[h, t, r] = hough(img_edge);
peak = houghpeaks(h, 5, 'threshold', ceil(0.3 * max(h(:))));
% `line`: A struct with 4 fields (point1, point2, theta, rho).
% line = houghlines(img_edge, t, r, peak, 'FillGap', 5, 'MinLength', 7);
line = houghlines(img_edge, t, r, peak);
imshow(img_gray);
hold on

xy_len = zeros(1, length(line));
max_len = 0;
for k = 1: length(line)
    xy = [line(k).point1; line(k).point2];
%     plot(xy(:, 1), xy(:, 2), 'LineWidth', 2, 'Color', 'green');
%     plot(xy(1, 1), xy(1, 2), 'o', 'LineWidth', 2, 'Color', 'blue');
%     plot(xy(2, 1), xy(2, 2), 'o', 'LineWidth', 2, 'Color', 'red');
    % Distance between 2 points.
    len = norm(line(k).point1 - line(k).point2);
    xy_len(1, k) = len;
end

% Sort in descending order.
sorted_len = sort(xy_len, 'descend');
rank = zeros(1, 3);
% Record the top 3 longest lines.
rank(1) = find(xy_len == sorted_len(1));
rank(2) = find(xy_len == sorted_len(2));
rank(3) = find(xy_len == sorted_len(3));

long_1 = [line(rank(1)).point1; line(rank(1)).point2];
long_2 = [line(rank(2)).point1; line(rank(2)).point2];
long_3 = [line(rank(3)).point1; line(rank(3)).point2];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Part 03 - Show image of subquestion 1, original image, and binary image.
% Show 3 lines.
% Color of lines: Longest: blue; Second longest: red; Third longest: green.

plot(long_1(:, 1), long_1(:, 2), 'LineWidth', 2, 'Color', 'blue');
plot(long_2(:, 1), long_2(:, 2), 'LineWidth', 2, 'Color', 'red');
plot(long_3(:, 1), long_3(:, 2), 'LineWidth', 2, 'Color', 'green');
title('\fontsize{16}\color{red}Top3 longest straight lines');

figure;
subplot(2, 2, 1);
imshow(img);
title('\fontsize{16}Original image');

subplot(2, 2, 2);
imshow(img_edge);
title('\fontsize{16}Binary image');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Part 04 - Find all regions and show.
% Binary image.
bw = im2bw(img, graythresh(img));

% Extract contours, and returns cell `b` (contours) and matrix `l` (region
% tags).
[b, l] = bwboundaries(bw, 'noholes');

subplot(2, 2, 3);
imshow(label2rgb(l, @jet, [.5 .5 .5]));
title('\fontsize{16}All regions');
hold on

for k = 1: length(b)
    bound = b{k};
    plot(bound(:, 2), bound(:, 1) , 'w', 'LineWidth', 1);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Part 05 - Find top 3 largest regions and show.
number = zeros(1, length(b));
index_largest = zeros(3, 1);

for i = 1: length(b)
    number(i) = sum(sum(l == i));
end

for i = 1: 3
    tmpIndex = find(number == max(number));
    number(tmpIndex) = 0;

    index_largest(i) = tmpIndex; 
end

for i = 1: IMG_SIZE(1)
    for j = 1: IMG_SIZE(2)
        if ismember(l(i, j), index_largest) == 0
            l(i, j) = 0;
        end
    end
end

subplot(2, 2, 4);
imshow(img);
hold on
imshow(label2rgb(l, @jet, [.5 .5 .5]))  
title('\fontsize{16}\color{red}Top3 largest regions'); 

for k = 1: length(b)
    bound = b{k}; 
    plot(bound(:, 2), bound(:, 1), 'w', 'LineWidth', 1)    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Part 05 - Save images.
SAVE_PATH = 'Result_Exp06\';
saveas(1, [SAVE_PATH, strcat('StraightLines_', IMG_NAME)]);
saveas(2, [SAVE_PATH, strcat('Comparison_', IMG_NAME)]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

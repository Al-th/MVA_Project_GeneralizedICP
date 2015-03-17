clc
init;
subSampleStep = 10
nbNeighbors = 20;
[A,covA,poseA] = loadDBData('data/hannover1/scan000',nbNeighbors);
[B,covB,poseB] = loadDBData('data/hannover1/scan004',nbNeighbors);

gtTransform(1) = poseA(2,1)-poseB(2,1);
gtTransform(2) = poseA(2,2)-poseB(2,2);
gtTransform(3) = poseA(2,3)-poseB(2,3);
gtTransform(4) = poseA(1,1)-poseB(1,1);
gtTransform(5) = poseA(1,2)-poseB(1,2);
gtTransform(6) = poseA(1,3)-poseB(1,3);

clear poseA;
clear poseB;

%Subsample 
A = A(1:subSampleStep:end,:);
covA = covA(1:subSampleStep:end,:,:);
B = B(1:subSampleStep:end,:);
covB = covB(1:subSampleStep:end,:,:);



initTransform = gtTransform;

initTransform(1:3) = degtorad(initTransform(1:3))
initTransform(1) = initTransform(1)+degtorad(5);
initTransform(2) = initTransform(2)-degtorad(15);
initTransform(3) = initTransform(3)-degtorad(10);
initTransform(4) = -initTransform(4)+20;
initTransform(5) = initTransform(5)-10;
initTransform(6) = initTransform(6)+15;

%%
figure(2);

n_gicp = [];
n_sicp = [];
dm = [];
for i = 1:8
    fileName = ['./Test/info_dmax_hannover_gicp' int2str(i) '.mat'];
    tempInfo = load(fileName);
    tempInfo = tempInfo.info_gicp{end};
    endTransformation = tempInfo.evolution_transformation(end,:)
    A_trans = transformPointCloud(A,endTransformation);
    err = computeAverageErrorWithNN(B,A_trans)
    n_gicp = [n_gicp err];
    dm = [dm tempInfo.dMax]
    
    figure(2);
    hold on;
    plot(tempInfo.size_subset,'b');
    hold off;
    
    fileName = ['./Test/info_dmax_hannover_sicp' int2str(i) '.mat'];
    tempInfo = load(fileName);
    tempInfo = tempInfo.info_sicp{end};
    endTransformation = tempInfo.evolution_transformation(end,:)
    A_trans = transformPointCloud(A,endTransformation);
    err = computeAverageErrorWithNN(B,A_trans)
    n_sicp = [n_sicp err];
    
    figure(2);
    hold on;
    plot(tempInfo.size_subset,'r');
    hold off;
    
    pause();
end

figure(1);
hold on;
plot(dm,n_gicp,'r','LineWidth',2);
plot(dm,n_sicp,'b','LineWidth',2);
hold off;
axis([0 2000 40 70]);
xlabel('dmax (cm)');
ylabel('Average error (cm)');
title('Hannover scans (1500 points)');
legend('Generalized ICP','Standard ICP');
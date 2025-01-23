filename = "hologram3pixels.png";
image = double(imread(filename));
intensity_mat = image / 255;

spectrum = fftshift(fft2(intensity_mat));
mag_spectrum = log(abs(spectrum));

normalized_mag = mat2gray(mag_spectrum);

[cropped_area, rect] = imcrop(normalized_mag);

x_start = round(rect(1));
y_start = round(rect(2));
width = round(rect(3));
height = round(rect(4));
cropped_frequencies = spectrum(y_start:y_start+height-1, x_start:x_start+width-1);  % isolate the wanted frequencies

% calculate shifts for moving cropped region at the center
[h, w] = size(spectrum);
horizontal_shift = floor(h/2) - floor((y_start+(height/2)));
vertical_shift = floor(w/2) - floor((x_start+(width/2)));

y_start = y_start + horizontal_shift;
x_start = x_start + vertical_shift;

% build new spectrum with the wanted frequencies at the center
new_spectrum = zeros(h, w);
new_spectrum(y_start:y_start+height-1, x_start:x_start+width-1) = cropped_frequencies;

% reconstruct wavefront
reconstruction = ifft2(ifftshift(new_spectrum));

distance = 185e-3;  % this distance was determined by checking a wide range with the for loop below
lambda = 532e-9;
pixel_size = 3.45e-6;

%for d = 100:200
%    prop_wavefront = AngularSpectrum(reconstruction,d*10^-3,lambda,pixel_size);
%    amplitudes = mat2gray(abs(prop_wavefront));
%    phase_mat_prop = mat2gray(angle(prop_wavefront));
%    imagesc(amplitudes);
%    colormap('gray');
%    title(['Amplitudes at distance = ', num2str(d), ' mm']);
%    pause(0.1);
%end

prop_wavefront = AngularSpectrum(reconstruction,distance,lambda,pixel_size);
amplitudes = mat2gray(abs(prop_wavefront));
phases = mat2gray(angle(prop_wavefront));

imagesc(amplitudes);
colormap('gray');
exportgraphics(gcf, 'amplitudes3pixels.png', 'Resolution', 300);
imagesc(phases);
colormap('gray');
exportgraphics(gcf, 'phases3pixels.png', 'Resolution', 300);

function bad_mask = get_frame_mask(refrec, type)

if ~exist('type', 'var') || isempty(type)
    type = 'maxcorr'; 
end

if strcmpi(type, 'maxcorr') 
    bad_mask = false(length(refrec.EEGchans), refrec.samples);
    win_frames = refrec.corr_win * refrec.srate;
    frame_inc = round(win_frames / 2); % Half number of frames on each side
    max_corr = (refrec.max_corr(:, refrec.EEGchans))';
    num_windows = floor(refrec.samples / win_frames);
    for k = 2:(num_windows - 2) % Ignore last two time windows to stay in range
        sindex = k*(win_frames - 1) - frame_inc;
        eindex = k*(win_frames - 1) + frame_inc;
        findex = sindex:eindex;
        mask = max_corr(:, k) < refrec.corr_thresh;
        window_mask = repmat(mask, 1, length(findex));
        bad_mask(:, findex) = bad_mask(:, findex) | window_mask;
    end;
elseif  strcmpi(type, 'ransac') 
    %% Ransac bad
    window_len = refrec.ransac_win*refrec.srate;
    offsets = 1:window_len:refrec.samples-window_len;
    W = length(offsets);
    bad_mask = false(length(refrec.EEGchans), refrec.samples);
    ransac_corr = refrec.ransac_corr(refrec.EEGchans, :);
    for k = 1:W
        sindex = offsets(k);
        eindex = offsets(k) + window_len - 1;
        findex = sindex:eindex;
        mask = ransac_corr(:, k) < refrec.ransac_thresh;
        window_mask = repmat(mask, 1, length(findex));
        bad_mask(:, findex) = bad_mask(:, findex) | window_mask;
    end
else
    error('type must be maxcorr or ransac');
end
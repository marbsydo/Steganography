function steganography_statistics(imc, imc_stego, secret_msg_bin, extracted_msg_bin)
% steganography_statistics() Show metrics about before/after steganography
% INPUTS
%    imc               - Original image (one channel)
%    imc_stego         - Steganographic image (one channel)
%    secret_msg_bin    - Message before encoding (in binary)
%    extracted_msg_bin - Message after encoding (in binary)
% OUTPUTS
%    Prints out statistics.

%@@ Whether to output the message decoded from binary
output_message_strings = false;

%@@ Whether to calculate message similarity at binary level
calculate_message_similarity = true;

%@@ Leave at false - spelling correction is far too slow
try_correcting_spelling = false;

if calculate_message_similarity
    % Calculate message similarity
    msg_similarity = py_string_similarity(char(secret_msg_bin + 48), char(extracted_msg_bin + 48));
end

% Convert binary messages to string
secret_msg_str = bin2str(secret_msg_bin);
extracted_msg_str = bin2str(extracted_msg_bin);

if try_correcting_spelling
    % Try performing spelling correction on the output
    corrected_msg_str = py_spelling(extracted_msg_str);
    corrected_msg_bin = str2bin(corrected_msg_str);
    msg_similarity_corrected = py_string_similarity(char(secret_msg_bin + 48), char(corrected_msg_bin + 48));
end
    
% Calculate error
imc_error = (imc - imc_stego) .^ 2;
imc_error_sum = sum(imc_error);

% Show statistics
fprintf('Image error: %d\n', sum(imc_error_sum));

if output_message_strings
    fprintf('Encoded message: %s\n', secret_msg_str);
    fprintf('Decoded message: %s\n', extracted_msg_str);

    if try_correcting_spelling
        fprintf('Corrected message: %s\n', corrected_msg_str);
    end
end

if calculate_message_similarity
    fprintf('Message similarity: ~%2.2f%%\n', msg_similarity * 100);
end
    
if try_correcting_spelling
    % TODO: Similarity is biased towards shorter strings
    % The correct string often comes out shorter because of the processing
    fprintf('Corrected similarity: ~%2.2f%%\n', msg_similarity_corrected * 100);
end

end

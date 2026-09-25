# Android MediaCodec audio decoder tests. These reuse the samples and reference
# outputs of the native decoder tests, and must run on an Android device, e.g.
# via TARGET_EXEC. The platform decoders are not bitexact with the native ones,
# so the lossy codecs are compared by standard deviation.

MEDIACODEC_OPUS_SAMPLES = $(addprefix testvector, 01 02 03 04 05 06 07 08 09 10 11 12) \
                          silk-lbrr silk-lbrr-mono tron.6ch.tinypkts

FATE_MEDIACODEC_OPUS-$(call FILTERDEMDECENCMUX, ARESAMPLE, MATROSKA, OPUS_MEDIACODEC, PCM_S16LE, PCM_S16LE, PIPE_PROTOCOL) += $(addprefix fate-mediacodec-opus-,$(MEDIACODEC_OPUS_SAMPLES))

$(FATE_MEDIACODEC_OPUS-yes): CMD = ffmpeg -c:a opus_mediacodec -i $(TARGET_SAMPLES)/opus/$(@:fate-mediacodec-opus-%=%).mka -f s16le -af aresample -
$(FATE_MEDIACODEC_OPUS-yes): REF = $(SAMPLES)/opus/$(@:fate-mediacodec-opus-%=%).dec
fate-mediacodec-opus-testvector05 fate-mediacodec-opus-testvector06: REF = $(SAMPLES)/opus/$(@:fate-mediacodec-opus-%=%)_v2.dec
$(FATE_MEDIACODEC_OPUS-yes): CMP = stddev
$(FATE_MEDIACODEC_OPUS-yes): CMP_UNIT = s16
$(FATE_MEDIACODEC_OPUS-yes): FUZZ = 3
fate-mediacodec-opus-testvector12: FUZZ = 15
fate-mediacodec-opus-silk-lbrr: CMP_SHIFT = -4
fate-mediacodec-opus-silk-lbrr: SIZE_TOLERANCE = 4
fate-mediacodec-opus-silk-lbrr: FUZZ = 12
fate-mediacodec-opus-silk-lbrr-mono: CMP_SHIFT = 8
fate-mediacodec-opus-silk-lbrr-mono: SIZE_TOLERANCE = 8
fate-mediacodec-opus-silk-lbrr-mono: FUZZ = 400

# The remaining Vorbis samples differ too much from the reference outputs to be
# a useful check.
MEDIACODEC_VORBIS_SAMPLES = 1.0.1-test_small 1.0-test_small chain-test1_small    \
                            chain-test2_small highrate-test_small mono_small     \
                            rc1-test_small rc2-test2_small rc2-test_small        \
                            rc3-test_small 6

FATE_MEDIACODEC_VORBIS-$(call PCM, OGG, VORBIS_MEDIACODEC, ARESAMPLE_FILTER) += $(addprefix fate-mediacodec-vorbis-,$(MEDIACODEC_VORBIS_SAMPLES))

$(FATE_MEDIACODEC_VORBIS-yes): CMD = pcm -c:a vorbis_mediacodec -i $(TARGET_SAMPLES)/vorbis/$(@:fate-mediacodec-vorbis-%=%).ogg
$(FATE_MEDIACODEC_VORBIS-yes): REF = $(SAMPLES)/vorbis/$(@:fate-mediacodec-vorbis-%=%).pcm
$(FATE_MEDIACODEC_VORBIS-yes): CMP = stddev
$(FATE_MEDIACODEC_VORBIS-yes): CMP_UNIT = s16
$(FATE_MEDIACODEC_VORBIS-yes): FUZZ = 3
fate-mediacodec-vorbis-highrate-test_small: FUZZ = 20
fate-mediacodec-vorbis-6: SIZE_TOLERANCE = 9948

# Only 16-bit sources, as the decoder is not configured for higher bit depths.
FATE_MEDIACODEC_FLAC-$(call ENCMUX, FLAC, FLAC, FLAC_MEDIACODEC_DECODER PIPE_PROTOCOL) += \
             fate-mediacodec-flac-16-chmode-indep                       \
             fate-mediacodec-flac-16-chmode-left_side                   \
             fate-mediacodec-flac-16-chmode-mid_side                    \
             fate-mediacodec-flac-16-chmode-right_side                  \
             fate-mediacodec-flac-16-fixed                              \
             fate-mediacodec-flac-16-lpc-cholesky                       \
             fate-mediacodec-flac-16-lpc-levinson                       \
             fate-mediacodec-flac-rice-params                           \

fate-mediacodec-flac-16-chmode-%: OPTS = -ch_mode $(@:fate-mediacodec-flac-16-chmode-%=%)
fate-mediacodec-flac-16-fixed:    OPTS = -lpc_type fixed
fate-mediacodec-flac-16-lpc-%:    OPTS = -lpc_type $(@:fate-mediacodec-flac-16-lpc-%=%)

fate-mediacodec-flac-16-%: REF = $(SAMPLES)/audio-reference/luckynight_2ch_44kHz_s16.wav
fate-mediacodec-flac-rice-params: REF = $(SAMPLES)/audio-reference/chorusnoise_2ch_44kHz_s16.wav
$(FATE_MEDIACODEC_FLAC-yes): CMD = enc_dec_pcm_decoder flac_mediacodec flac wav s16le $(subst $(SAMPLES),$(TARGET_SAMPLES),$(REF)) -c flac $(OPTS)
$(FATE_MEDIACODEC_FLAC-yes): CMP = oneoff
$(FATE_MEDIACODEC_FLAC-yes): FUZZ = 0

FATE_MEDIACODEC = $(FATE_MEDIACODEC_OPUS-yes) $(FATE_MEDIACODEC_VORBIS-yes) $(FATE_MEDIACODEC_FLAC-yes)

FATE_SAMPLES_FFMPEG += $(FATE_MEDIACODEC)
fate-mediacodec-opus: $(FATE_MEDIACODEC_OPUS-yes)
fate-mediacodec-vorbis: $(FATE_MEDIACODEC_VORBIS-yes)
fate-mediacodec-flac: $(FATE_MEDIACODEC_FLAC-yes)
fate-mediacodec: $(FATE_MEDIACODEC)

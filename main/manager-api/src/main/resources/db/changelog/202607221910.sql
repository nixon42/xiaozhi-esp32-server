-- New Changelog Migration for i18n Translation of AI Model Providers and Model Configs
-- Date: 2026-07-22

-- 1. Update Provider Names (Intent, Memory, Plugins, VAD, ASR, TTS, VLLM)
UPDATE `ai_model_provider` SET `name` = 'No Intent Recognition' WHERE `id` = 'SYSTEM_Intent_nointent';
UPDATE `ai_model_provider` SET `name` = 'External LLM Intent Recognition' WHERE `id` = 'SYSTEM_Intent_intent_llm';
UPDATE `ai_model_provider` SET `name` = 'LLM Autonomous Function Call' WHERE `id` = 'SYSTEM_Intent_function_call';
UPDATE `ai_model_provider` SET `name` = 'Local Short-term Memory (Summarized)' WHERE `id` = 'SYSTEM_Memory_mem_local_short';
UPDATE `ai_model_provider` SET `name` = 'Report Chat Logs Only (No Summary)' WHERE `id` = 'SYSTEM_Memory_mem_report_only';
UPDATE `ai_model_provider` SET `name` = 'Web Search' WHERE `id` = 'SYSTEM_PLUGIN_WEB_SEARCH';
UPDATE `ai_model_provider` SET `name` = 'Call Device Action' WHERE `id` = 'SYSTEM_PLUGIN_CALL_DEVICE';

UPDATE `ai_model_provider` SET `name` = 'Voice Activity Detection (Silero)' WHERE `id` = 'SYSTEM_VAD_SileroVAD';
UPDATE `ai_model_provider` SET `name` = 'Doubao Speech Recognition (Streaming)' WHERE `id` = 'SYSTEM_ASR_DoubaoStreamASR';
UPDATE `ai_model_provider` SET `name` = 'Doubao Speech Recognition 2.0 (Streaming)' WHERE `id` = 'SYSTEM_ASR_DoubaoStreamASRV2';
UPDATE `ai_model_provider` SET `name` = 'Tencent Speech Recognition' WHERE `id` = 'SYSTEM_ASR_TencentASR';
UPDATE `ai_model_provider` SET `name` = 'Baidu Speech Recognition' WHERE `id` = 'SYSTEM_ASR_BaiduASR';
UPDATE `ai_model_provider` SET `name` = 'Doubao Speech Recognition' WHERE `id` = 'SYSTEM_ASR_DoubaoASR';
UPDATE `ai_model_provider` SET `name` = 'Aliyun Speech Recognition' WHERE `id` = 'SYSTEM_ASR_AliyunASR';
UPDATE `ai_model_provider` SET `name` = 'Aliyun Speech Recognition (Streaming)' WHERE `id` = 'SYSTEM_ASR_AliyunStreamASR';

UPDATE `ai_model_provider` SET `name` = 'Aliyun TTS (Streaming)' WHERE `id` = 'SYSTEM_TTS_AliyunStreamTTS';
UPDATE `ai_model_provider` SET `name` = 'IndexTTS (Streaming)' WHERE `id` = 'SYSTEM_TTS_IndexStreamTTS';
UPDATE `ai_model_provider` SET `name` = 'PaddleSpeech (Streaming)' WHERE `id` = 'SYSTEM_TTS_PaddleSpeechTTS';
UPDATE `ai_model_provider` SET `name` = 'Doubao Voice Synthesis' WHERE `id` = 'SYSTEM_TTS_DoubaoTTS';
UPDATE `ai_model_provider` SET `name` = 'Tencent Voice Synthesis' WHERE `id` = 'SYSTEM_TTS_TencentTTS';

UPDATE `ai_model_provider` SET `name` = 'Zhipu Vision AI' WHERE `id` = 'SYSTEM_VLLM_ChatGLMVLLM';
UPDATE `ai_model_provider` SET `name` = 'Qwen Vision Model' WHERE `id` = 'SYSTEM_VLLM_QwenVLVLLM';

-- 2. Update Provider Field Labels
UPDATE `ai_model_provider` SET `fields` = '[{"key":"llm","label":"Referenced LLM Model","type":"string"}]' WHERE `id` = 'SYSTEM_Intent_intent_llm';
UPDATE `ai_model_provider` SET `fields` = '[{"key":"llm","label":"LLM Model","type":"string"}]' WHERE `id` = 'SYSTEM_Memory_mem_local_short';

-- 3. Update Model Config Names and Remarks
UPDATE `ai_model_config` SET `model_name` = 'No Intent Recognition', `remark` = 'No Intent Recognition Configuration:\n1. No intent recognition performed\n2. All dialogues passed directly to LLM\n3. No extra configuration required\n4. Suitable for simple dialogue scenarios' WHERE `id` = 'Intent_nointent';
UPDATE `ai_model_config` SET `model_name` = 'External LLM Intent Recognition', `remark` = 'LLM Intent Recognition Configuration:\n1. Uses an independent LLM for intent recognition\n2. Defaults to using selected_module.LLM model\n3. Can be configured to use independent LLMs (e.g. ChatGLMLLM)\n4. Highly versatile, but increases processing latency' WHERE `id` = 'Intent_intent_llm';
UPDATE `ai_model_config` SET `model_name` = 'LLM Autonomous Function Call', `remark` = 'LLM Autonomous Function Calling Configuration' WHERE `id` = 'Intent_function_call';

UPDATE `ai_model_config` SET `model_name` = 'Zhipu AI' WHERE `id` = 'LLM_ChatGLMLLM';
UPDATE `ai_model_config` SET `model_name` = 'Ollama Local Model' WHERE `id` = 'LLM_OllamaLLM';
UPDATE `ai_model_config` SET `model_name` = 'Tongyi Qianwen (Qwen)' WHERE `id` = 'LLM_AliLLM';
UPDATE `ai_model_config` SET `model_name` = 'Bailian Agent Application' WHERE `id` = 'LLM_AliAppLLM';
UPDATE `ai_model_config` SET `model_name` = 'Doubao LLM' WHERE `id` = 'LLM_DoubaoLLM';
UPDATE `ai_model_config` SET `model_name` = 'Google Gemini' WHERE `id` = 'LLM_GeminiLLM';

UPDATE `ai_model_config` SET `model_name` = 'Voice Activity Detection' WHERE `id` = 'VAD_SileroVAD';
UPDATE `ai_model_config` SET `model_name` = 'Doubao Speech Recognition (Streaming)' WHERE `id` = 'ASR_DoubaoStreamASR';
UPDATE `ai_model_config` SET `model_name` = 'Doubao Speech Recognition 2.0 (Streaming)' WHERE `id` = 'ASR_DoubaoStreamASRV2';
UPDATE `ai_model_config` SET `model_name` = 'Tencent Speech Recognition' WHERE `id` = 'ASR_TencentASR';
UPDATE `ai_model_config` SET `model_name` = 'Baidu Speech Recognition' WHERE `id` = 'ASR_BaiduASR';
UPDATE `ai_model_config` SET `model_name` = 'Doubao Speech Recognition' WHERE `id` = 'ASR_DoubaoASR';
UPDATE `ai_model_config` SET `model_name` = 'Aliyun Speech Recognition' WHERE `id` = 'ASR_AliyunASR';

UPDATE `ai_model_config` SET `model_name` = 'Aliyun TTS (Streaming)' WHERE `id` = 'TTS_AliyunStreamTTS';
UPDATE `ai_model_config` SET `model_name` = 'IndexTTS (Streaming)' WHERE `id` = 'TTS_IndexStreamTTS';
UPDATE `ai_model_config` SET `model_name` = 'PaddleSpeech (Streaming)' WHERE `id` = 'TTS_PaddleSpeechTTS';
UPDATE `ai_model_config` SET `model_name` = 'Doubao Voice Synthesis' WHERE `id` = 'TTS_DoubaoTTS';
UPDATE `ai_model_config` SET `model_name` = 'Tencent Voice Synthesis' WHERE `id` = 'TTS_TencentTTS';

UPDATE `ai_model_config` SET `model_name` = 'Zhipu Vision AI' WHERE `id` = 'VLLM_ChatGLMVLLM';
UPDATE `ai_model_config` SET `model_name` = 'Qwen Vision Model' WHERE `id` = 'VLLM_QwenVLVLLM';

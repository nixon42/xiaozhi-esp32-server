-- New Changelog Migration for i18n Translation of AI Model Providers and Model Configs
-- Date: 2026-07-22

-- 1. Update Provider Names
UPDATE `ai_model_provider` SET `name` = 'No Intent Recognition' WHERE `id` = 'SYSTEM_Intent_nointent';
UPDATE `ai_model_provider` SET `name` = 'External LLM Intent Recognition' WHERE `id` = 'SYSTEM_Intent_intent_llm';
UPDATE `ai_model_provider` SET `name` = 'LLM Autonomous Function Call' WHERE `id` = 'SYSTEM_Intent_function_call';
UPDATE `ai_model_provider` SET `name` = 'Local Short-term Memory (Summarized)' WHERE `id` = 'SYSTEM_Memory_mem_local_short';
UPDATE `ai_model_provider` SET `name` = 'Report Chat Logs Only (No Summary)' WHERE `id` = 'SYSTEM_Memory_mem_report_only';
UPDATE `ai_model_provider` SET `name` = 'Web Search' WHERE `id` = 'SYSTEM_PLUGIN_WEB_SEARCH';
UPDATE `ai_model_provider` SET `name` = 'Call Device Action' WHERE `id` = 'SYSTEM_PLUGIN_CALL_DEVICE';

-- 2. Update Provider Field Labels (Replacing Chinese labels in JSON string)
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

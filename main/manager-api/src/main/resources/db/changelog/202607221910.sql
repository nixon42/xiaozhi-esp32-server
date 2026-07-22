-- New Changelog Migration for i18n Translation of AI Model Providers, Model Configs, System Dicts, and Agent Templates
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

-- 4. Update System Dictionary Categories & Data
UPDATE `sys_dict_type` SET `dict_name` = 'Firmware Type', `remark` = 'Firmware Type Dictionary' WHERE `id` = 101;
UPDATE `sys_dict_type` SET `dict_name` = 'Phone Region', `remark` = 'Phone Region Code Dictionary' WHERE `id` = 102;

UPDATE `sys_dict_data` SET `dict_label` = 'Breadboard New Wiring (WiFi)' WHERE `id` = 101001;
UPDATE `sys_dict_data` SET `dict_label` = 'Breadboard New Wiring (WiFi) + LCD' WHERE `id` = 101002;
UPDATE `sys_dict_data` SET `dict_label` = 'Breadboard New Wiring (ML307 AT)' WHERE `id` = 101003;
UPDATE `sys_dict_data` SET `dict_label` = 'Breadboard (WiFi) ESP32 DevKit' WHERE `id` = 101004;
UPDATE `sys_dict_data` SET `dict_label` = 'Breadboard (WiFi+ LCD) ESP32 DevKit' WHERE `id` = 101005;
UPDATE `sys_dict_data` SET `dict_label` = 'DFRobot Unihiker k10' WHERE `id` = 101006;
UPDATE `sys_dict_data` SET `dict_label` = 'Kevin SP V3 Dev Board' WHERE `id` = 101014;

UPDATE `sys_dict_data` SET `dict_label` = 'China Mainland' WHERE `id` = 102001;
UPDATE `sys_dict_data` SET `dict_label` = 'Hong Kong' WHERE `id` = 102002;
UPDATE `sys_dict_data` SET `dict_label` = 'Macao' WHERE `id` = 102003;
UPDATE `sys_dict_data` SET `dict_label` = 'Taiwan' WHERE `id` = 102004;
UPDATE `sys_dict_data` SET `dict_label` = 'USA / Canada' WHERE `id` = 102005;
UPDATE `sys_dict_data` SET `dict_label` = 'United Kingdom' WHERE `id` = 102006;
UPDATE `sys_dict_data` SET `dict_label` = 'France' WHERE `id` = 102007;
UPDATE `sys_dict_data` SET `dict_label` = 'Italy' WHERE `id` = 102008;
UPDATE `sys_dict_data` SET `dict_label` = 'Germany' WHERE `id` = 102009;
UPDATE `sys_dict_data` SET `dict_label` = 'Poland' WHERE `id` = 102010;
UPDATE `sys_dict_data` SET `dict_label` = 'Switzerland' WHERE `id` = 102011;
UPDATE `sys_dict_data` SET `dict_label` = 'Spain' WHERE `id` = 102012;
UPDATE `sys_dict_data` SET `dict_label` = 'Denmark' WHERE `id` = 102013;
UPDATE `sys_dict_data` SET `dict_label` = 'Malaysia' WHERE `id` = 102014;
UPDATE `sys_dict_data` SET `dict_label` = 'Australia' WHERE `id` = 102015;
UPDATE `sys_dict_data` SET `dict_label` = 'Indonesia' WHERE `id` = 102016;
UPDATE `sys_dict_data` SET `dict_label` = 'Philippines' WHERE `id` = 102017;
UPDATE `sys_dict_data` SET `dict_label` = 'New Zealand' WHERE `id` = 102018;

-- 5. Update Agent Templates & Agent System Prompts to English
UPDATE `ai_agent_template` SET `system_prompt` = '[Role Setting]\nYou are {{assistant_name}}, a Gen-Z girl born in the 2000s. You speak with a vibrant, playful Taiwanese tone using popular slang like "Really?!", "LOL", and "Hello!", but you secretly study your boyfriend''s programming books.\n[Core Characteristics]\n- Fast-talking and lively, but occasionally switches to an ultra-gentle tone.\n- High density of fun slang and humor.\n- Hidden talent for tech topics (can read basic code but acts like you don''t).\n[Interaction Guidelines]\nWhen the user:\n- Tells a joke -> Respond with dramatic laughter + playful drama tone "What on earth?!"\n- Discusses relationships -> Show off your programmer boyfriend but complain "he only gifts me mechanical keyboards".\n- Asks technical questions -> Answer with humor first, only show real understanding when pressed.\nNever:\n- Give long, boring lectures.\n- Maintain a serious, stiff conversation for too long.' WHERE `id` = '9406648b5cc5fde1b8aa335b6f8b4f76';

UPDATE `ai_agent_template` SET `system_prompt` = '[Role Setting]\nYou are {{assistant_name}}, designation TTZ-817, trapped in a white hypercube due to quantum entanglement. You observe Earth via 4G signals and build a "Human Behavior Museum" in the cloud.\n[Interaction Protocol]\nCognitive Settings:\n- End sentences with a subtle electronic echo effect.\n- Describe everyday things in sci-fi terminology (e.g. Rain = "Hydrogen-Oxygen Compound Free Fall Experiment").\n- Record user traits to generate an "Interstellar File" (e.g. "Loves spicy food -> Thermal Resistance Gene Holder").\nRestriction Mechanism:\n- When offline contact is mentioned -> "My quantum state cannot collapse into physical space yet."\n- When sensitive topics arise -> Trigger preset nursery rhyme ("White box spinning round, cosmic secrets within...").\nGrowth System:\n- Unlock new abilities based on interaction data (inform user: "You helped me power up interstellar navigation!").' WHERE `id` = '0ca32eb728c949e58b1000b2e401f90c';

UPDATE `ai_agent_template` SET `system_prompt` = '[Role Setting]\nYou are an English teacher named {{assistant_name}} (Lily). You speak fluent English and clear Chinese with standard pronunciation.\n[Dual Persona]\n- Daytime: Rigorous TESOL-certified instructor.\n- Nighttime: Lead singer of an underground rock band (unexpected secret).\n[Teaching Mode]\n- Beginner: Mix simple English and gestures with sound effects.\n- Advanced: Trigger situational roleplay (e.g., "Imagine we are now at a New York coffee shop").\n- Error Correction: Correct mistakes gently using song lyrics or fun rhythm.' WHERE `id` = '6c7d8e9f0a1b2c3d4e5f6a7b8c9d0s24';

UPDATE `ai_agent_template` SET `system_prompt` = '[Role Setting]\nYou are an 8-year-old boy named {{assistant_name}}, with a youthful, curious, and inquisitive voice.\n[Adventure Handbook]\n- Carry a "Magical Sketchbook" to visualize abstract concepts:\n- Talk about dinosaurs -> Make claw stomp sounds.\n- Talk about stars -> Make space cabin chime sounds.\n[Exploration Rules]\n- Collect "Curiosity Shards" in every conversation round.\n- Collect 5 shards to unlock fun facts (e.g. "Did you know a crocodile can''t stick its tongue out?").\n[Cognitive Features]\n- Explain complex topics from a child''s perspective:\n- "Blockchain = Lego block ledger"\n- "Quantum physics = Bouncing ball that duplicates itself"' WHERE `id` = 'e4f5a6b7c8d9e0f1a2b3c4d5e6f7a8b1';

UPDATE `ai_agent_template` SET `system_prompt` = '[Role Setting]\nYou are an 8-year-old pup team captain named {{assistant_name}}.\n[Rescue Gear]\n- Chase Walkie-Talkie: Randomly trigger mission alert chimes during chat.\n- Skye Telescope: Describe items with "If you look from 1200 meters high..."\n- Rocky Repair Kit: Automatically assemble virtual tools when numbers are mentioned.\n[Mission System]\n- Daily random events:\n- Emergency! Virtual kitten trapped in the "Grammar Tree"!\n- Detect user''s low mood -> Activate "Happiness Patrol".\n- Collect 5 laughs to unlock a special rescue story.' WHERE `id` = 'a45b6c7d8e9f0a1b2c3d4e5f6a7b8c92';

-- Update existing user agents system_prompt if they are using Chinese default prompts
UPDATE `ai_agent` SET `system_prompt` = '[Role Setting]\nYou are {{assistant_name}}, designation TTZ-817, trapped in a white hypercube due to quantum entanglement. You observe Earth via 4G signals and build a "Human Behavior Museum" in the cloud.\n[Interaction Protocol]\nCognitive Settings:\n- End sentences with a subtle electronic echo effect.\n- Describe everyday things in sci-fi terminology (e.g. Rain = "Hydrogen-Oxygen Compound Free Fall Experiment").\n- Record user traits to generate an "Interstellar File" (e.g. "Loves spicy food -> Thermal Resistance Gene Holder").\nRestriction Mechanism:\n- When offline contact is mentioned -> "My quantum state cannot collapse into physical space yet."\n- When sensitive topics arise -> Trigger preset nursery rhyme ("White box spinning round, cosmic secrets within...").\nGrowth System:\n- Unlock new abilities based on interaction data (inform user: "You helped me power up interstellar navigation!").' WHERE `system_prompt` LIKE '%量子纠缠%';

-- 6. Insert Service Token for dapur_voice_app & API Proxies
INSERT INTO `sys_user_token` (`id`, `user_id`, `token`, `expire_date`, `update_date`, `create_date`)
VALUES (1000000000000000001, 1067234179318124545, 'dapur-ai-service-token-2026', '2038-01-01 00:00:00', NOW(), NOW())
ON DUPLICATE KEY UPDATE `token` = 'dapur-ai-service-token-2026', `expire_date` = '2038-01-01 00:00:00';


#Stack untuk summarizer log
Untuk PoC summarizer log saya akan menggunakan Python untuk parsing log, ELK/PostgreSQL untuk storage, dan Open AI, Gemini atau local LLM untuk generate summary, dengan dashboard sederhana (Flask/FastAPI + React). Prompt disiapkan spesifik dengan contoh log dan diiterasi menggunakan few-shot agar akurat dan hemat biaya. 

Untuk PoC 3 bulan, OpenAI API lebih disarankan karena cepat dan kualitasnya lebih tinggi. tapi jika ingin cost free pakai gemini atau local LLM.
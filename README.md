# 🧠 MurtixEnvironment - Shareable WSL Agentic Developer Workspace

Selamat datang di **MurtixEnvironment**! Repositori ini berisi konfigurasi, rules, templates, dan automasi installer untuk mereplikasi environment pemrograman berbasis AI agent yang canggih (agentic workflow) milik **Rudie Sabilillah Azwan Murti (Murtix)** di WSL2 / Ubuntu.

Environment ini membagi proses development menjadi dua lapisan: **Planning & Orchestration** (dilakukan oleh Antigravity IDE atau Oh My Pi) dan **Parallel Execution** (dilakukan oleh Seiza Sub-agents). Semua agent terhubung ke satu memori jangka panjang terpadu (**Amneshia**) dan didukung oleh penemuan codebase berbasis graf (**codebase-memory-mcp**).

---

## 🏛️ Arsitektur & Alur Kerja (Workflow)

Environment ini mendukung dua jenis alur kerja utama:

```mermaid
graph TD
    subgraph Planning & Orchestration
        AG[Antigravity IDE] -- OR -- OMP[Oh My Pi Orchestrator]
    end

    subgraph Memory & Context
        AM[Amneshia Memory Hub]
        CM[Codebase Memory MCP]
        C7[Context7 Official Docs]
    end

    subgraph Parallel Execution
        SZ[Seiza sub-agent task runner]
        SZ_C[Coder Subagent]
        SZ_R[Reviewer Subagent]
        SZ_P[Planner Subagent]
    end

    AG -->|run_seiza_task| SZ
    OMP -->|run_seiza_task| SZ
    SZ --> SZ_C
    SZ --> SZ_R
    SZ --> SZ_P

    SZ_C -.->|Query Context| AM
    SZ_C -.->|Query Code Structure| CM
    SZ_C -.->|Query Library API| C7
```

### 1. Antigravity IDE + Seiza Sub-Agent (Project Manager & Sub-Agent)
*   **Peran Antigravity IDE:** Bertindak sebagai Project Manager di sisi Windows/IDE. Antigravity melakukan pemahaman tingkat tinggi, menganalisis permintaan user, memformulasikan rencana implementasi (`implementation_plan.md`), dan mengumpulkan persetujuan Anda.
*   **Peran Seiza:** Begitu rencana disetujui, Antigravity IDE **tidak** menulis kode file satu per satu secara manual. Sebaliknya, ia memanggil `run_seiza_task` dari MCP server Seiza. Seiza akan menjadwalkan DAG tugas, membagi pekerjaan, dan menjalankan sub-agent secara paralel (coder, planner, reviewer, tester) langsung di backend WSL2 Anda menggunakan model yang diarahkan oleh **9router**.

### 2. OMP (Oh My Pi) + Seiza Sub-Agent (CLI-First Orchestrator)
*   **Peran OMP:** Alternatif untuk alur kerja berbasis CLI. OMP bertindak sebagai CLI Orchestration Manager yang membagi tugas-tugas kompleks dan mendelegasikannya ke sub-agent Seiza.
*   **Peran Seiza:** Seiza melakukan eksekusi kode paralel di bawah kendali OMP, memperbarui database status, dan menulis output yang lengkap serta teruji.

---

## 🚀 Fitur Unggulan & Keuntungan Environment

Setiap tool dalam environment ini dipilih secara sengaja untuk mengatasi batasan LLM konvensional:

| Nama Tool | Deskripsi & Kegunaan Utama | Keuntungan & Fitur Unggulan |
| :--- | :--- | :--- |
| **Seiza Orchestrator** | Sub-agent execution engine dengan skema hub-and-spoke. | Membagi tugas berat menjadi sub-task paralel (Coder, Reviewer, Planner, Tester). Menghindari kepayahan single-agent. |
| **Amneshia (v2)** | SQLite FTS5 Memory Hub & Knowledge Graph. | Menyimpan data user, preferensi stack, keputusan arsitektur, dan hubungan antar entitas secara permanen lintas sesi pemrograman. |
| **codebase-memory-mcp** | C-based Codebase Graph Indexer (Tree-Sitter). | Mengubah codebase menjadi struktur graph yang dapat di-query. **Mengurangi konsumsi token agent sebesar 80-95%** dengan menghilangkan scanning file mentah/grep berulang. |
| **Context7** | Official Library & Framework Documentation Engine. | Mengambil dokumentasi resmi terbaru (React, Next.js, Laravel, Tailwind, dll.) secara real-time. Mencegah agent menulis kode dengan sintaks usang/halusinasi API. |
| **9router** | Local daemon model router. | Mengarahkan LLM request ke model free/lokal (seperti `gemini-3-flash`) sebagai fallback otomatis sebelum menggunakan model berbayar jika kuota habis. |
| **Sequential Thinking** | Dynamic multi-step reasoning tool. | Memaksa agent berpikir secara bertahap dan mengevaluasi hipotesis sebelum melakukan penulisan kode atau modifikasi file. |

---

## 🤖 AI-Agent Installation Prompt (Cara Cepat Pasang lewat AI)

Jika Anda membagikan workspace ini kepada teman Anda yang juga menggunakan AI Agent coding (seperti Claude Code, Cursor, Aider, atau Antigravity IDE), mereka dapat langsung melakukan **copy-paste** prompt di bawah ini ke AI agent mereka untuk proses instalasi instan.

> [!TIP]
> **Salin teks di bawah ini dan berikan ke AI Agent Anda:**
> ```text
> Tolong bantu saya mengonfigurasi dan memasang MurtixEnvironment di WSL saya.
> Saya telah meng-clone repository MurtixEnvironment. Silakan lakukan langkah berikut secara berurutan:
> 1. Periksa file 'install.sh' di root repository ini untuk memahami alur instalasinya.
> 2. Periksa apakah dependencies sistem seperti Node.js, npm, dan git sudah terpasang.
> 3. Jalankan './install.sh' untuk:
>    - Mengunduh codebase-memory-mcp dari DeusData.
>    - Meng-clone dan mem-build Amneshia dan Seiza ke folder ~/projects/.
>    - Menyalin rules/GEMINI.md ke ~/.gemini/GEMINI.md dan rules/SEIZA_RULES.md ke ~/.seiza/RULES.md.
>    - Menggabungkan MCP config baru dari templates/mcp_config.json.template ke ~/.gemini/config/mcp_config.json secara cerdas tanpa menghapus server MCP yang sudah saya miliki.
> 4. Jika terjadi error path atau perbedaan direktori pada sistem saya, tolong edit install.sh atau jalankan commands manual yang sesuai agar instalasi berhasil.
> 5. Laporkan hasilnya jika sudah selesai.
> ```

---

## 🛠️ Panduan Instalasi Manual (Langkah demi Langkah)

Jika Anda ingin menginstalnya secara mandiri via Terminal WSL2:

### 1. Persiapan
Pastikan sistem WSL2 Anda memiliki:
*   **Node.js** (versi >= 18)
*   **npm**
*   **git**
*   **curl**

### 2. Jalankan Installer Script
Masuk ke direktori repository dan jalankan:
```bash
chmod +x install.sh
./install.sh
```

Script akan memandu Anda untuk:
1. Memeriksa ketersediaan perintah `node`, `npm`, dan `git`.
2. Mengunduh biner `codebase-memory-mcp` (jika belum ada) ke `~/.local/bin/`.
3. Meng-clone repositori `Amneshia` dan `Seiza` dari akun GitHub **SabilMurti**, mem-build-nya, dan melakukan registrasi global.
4. Menyalin instruksi/rules agen (`GEMINI.md` dan `RULES.md`).
5. Meminta `Context7 API Key` dan `GitHub Personal Access Token` (opsional, tekan Enter untuk melewatinya).
6. Melakukan *smart merge* terhadap file `~/.gemini/config/mcp_config.json` agar server MCP yang sudah ada di PC Anda tidak hilang.

---

## ⚙️ Cara Menghubungkan MCP via Bridge (Amneshia & Seiza)

Seiza dan Amneshia mendukung fitur **MCP Bridge**. Setelah instalasi selesai:
*   **Amneshia** dapat menjembatani data dari `codebase-memory-mcp` untuk menyimpan metadata struktur codebase ke dalam long-term memory graph-nya.
*   **Seiza** secara otomatis mendelegasikan perintah penemuan kode kepada `codebase-memory-mcp` menggunakan bridge tool yang tersedia.

Pastikan path `codebase-memory-mcp` di `~/.gemini/config/mcp_config.json` menunjuk ke lokasi biner yang valid (default: `~/.local/bin/codebase-memory-mcp`).

---

*Dibuat dengan 🧠 dan ⚡ untuk efisiensi pemrograman tingkat lanjut oleh Sabil Murti.*

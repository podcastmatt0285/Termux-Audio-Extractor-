## 1. playlistSyncX.sh: YouTube Playlist Synchronization

**Purpose:** Ensure your local downloads remain in sync with an online YouTube playlist.

**Key Features:**
- Compare existing downloaded files with the current playlist.
- Download new items added to the playlist.
- Optionally remove local files no longer in the playlist.
- Maintain a sync log to track additions and deletions.

---

## 2. compressX.sh: File Compression Enhancer

**Purpose:** Extend file compression functionality with additional formats and customization.

**Key Features:**
- Support multiple compression formats, including `.zip`, `.tar.gz`, and `.7z`.
- Allow users to set custom compression levels (low, medium, high).
- Compress entire directories or individual files.
- Include error handling and a summary of compression results.

---

## 3. errorX.sh: Error Log Analyzer

**Purpose:** Provide an automated way to review and analyze error logs.

**Key Features:**
- Parse logs from failed downloads or extractions.
- Summarize errors and categorize them (e.g., network issues, invalid URLs, missing dependencies).
- Suggest potential fixes based on error patterns.
- Notify users via `termux-notification` about unresolved issues.

---

## 4. shareX.sh: File Sharing Script

**Purpose:** Enable seamless sharing of downloaded or extracted files.

**Key Features:**
- Use `termux-share` to send files to nearby devices or apps.
- Support for generating shareable cloud links (e.g., Google Drive or Dropbox integration, if possible).
- Share files or directories interactively or as batch operations.

---

## 5. statsX.sh: Usage and Stats Tracker

**Purpose:** Provide insights and summaries of repository activity and resource usage.

**Key Features:**
- Count and list downloaded or extracted files.
- Calculate total disk space usage for media files and logs.
- Generate summaries of user activity over a set period (e.g., daily, weekly, monthly).
- Include visualized stats like pie charts or usage trends (if terminal supports ASCII graphs).
# Cubyz-Ashframe-Server

Custom server modification specifically for hosting and running the **Ashframe** community server.

---

## Player Commands

| Command | Usage | Description |
| :--- | :--- | :--- |
| `/home add <name>` | `/home add house` | Saves your current location as your home and death respawn point. |
| `/home` | `/home` | Teleports you back to your saved home location. |
| `/tpa` | `/tpa @2` or `/tpa Nick` | Sends a peer-to-peer teleport request to a player (supports ID or Name). |
| `/tpaccept` | `/tpaccept` | Accepts a pending incoming teleport request. |
| `/back` | `/back` | Teleports you directly back to your last recorded position. |
| `/spawn` | `/spawn` | Teleports you instantly to the absolute global world spawn point. |
| `/playtime` | `/playtime` | Displays your total accumulated playtime on this server. |
| `/playtime list` | `/playtime list` | Opens the server-wide playtime leaderboard. |
| `/avatar` | `/avatar base:skin_name` | Modifies your character's active 3D model skin. |
| `/afk` | `/afk` | Toggles your status to away-from-keyboard and notifies the chat. |
| `/players` | `/players` | Displays a list of all currently connected online players. |

---

## Admin Commands

> **Note:** These commands require explicit `/command/prefix/admin` permissions to execute.

### Prefix Management
*   **Add a Prefix:**
    ```bash
    /prefix add @<playerIndex> <text>
    ```
    *Example:* `/prefix add @2 Admin` — Assigns a bracketed visual title to a player in chat.
*   **Remove a Prefix:**
    ```bash
    /prefix remove @<playerIndex>
    ```
    *Example:* `/prefix remove @2` — Strips the title and safely deallocates the string memory from the server.

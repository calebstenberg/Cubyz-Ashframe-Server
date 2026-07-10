# Cubyz-Ashframe-Server

Custom server modification specifically for hosting and running the **Ashframe** community server.

---

## Player Commands

| Syntax / Usage | Description |
| :--- | :--- |
| `/home add <name>` | Saves your current location as your home and death respawn point. |
| `/home` | Teleports you back to your saved home location. |
| `/home remove` | Deletes your saved home from your data profile. |
| `/tpa <player>` | Sends a peer-to-peer teleport request. *(Supports name or `@id`, e.g., `/tpa Nick` or `/tpa @2`)* |
| `/tpaccept` | Accepts a pending incoming teleport request. |
| `/back` | Teleports you directly back to your last recorded position. |
| `/spawn` | Teleports you instantly to the absolute global world spawn point. |
| `/playtime` | Displays your total accumulated playtime on this server. |
| `/playtime list` | Opens the server-wide playtime leaderboard. |
| `/avatar <skin>` | Modifies your character's active 3D model skin. *(e.g., `/avatar base:skin_name`)* |
| `/afk` | Toggles your status to away-from-keyboard and notifies the chat. |
| `/players` | Displays a list of all currently connected online players. |

---

## Admin Commands

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

> **Note:** These commands require explicit `/command/prefix/admin` permissions to execute.

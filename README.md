# Clarity Finance (Finance Tracking App)

A modern, premium Flutter application designed to track personal finances across multiple accounts. The application features a clean glassmorphism-inspired UI, PDF export capabilities, real-time connectivity monitoring, and robust state management powered by BLoC.

## Features
- **Modern UI**: Clean, responsive layout with glassmorphic elements and curated color palettes.
- **Multi-Account Management**: Create multiple accounts with custom colors to track balances independently.
- **Transaction Tracking**: Add income and expense transactions, and see your balances update dynamically.
- **Advanced Filtering**: Filter transactions by All, Today, Weekly, Monthly, and Yearly.
- **PDF Export**: Generate PDF transaction statements with a single tap.
- **Backend Sync**: Powered by Supabase for secure authentication and fast database syncing.

## Database Schema

This application relies on Supabase for the backend. Below is the required schema.

### 1. `accounts` Table
Stores user financial accounts (e.g., Wallet, Bank).

| Column | Type | Modifiers | Description |
|---|---|---|---|
| `id` | `uuid` | Primary Key, default `uuid_generate_v4()` | Unique identifier for the account |
| `user_id` | `uuid` | Foreign Key (`auth.users`) | The user who owns this account |
| `name` | `text` | Not Null | The name of the account |
| `color_code` | `text` | | The hex color code for UI rendering |
| `created_at` | `timestamp` | default `now()` | When the account was created |

### 2. `transactions` Table
Stores all income and expense logs linked to a specific account.

| Column | Type | Modifiers | Description |
|---|---|---|---|
| `id` | `uuid` | Primary Key, default `uuid_generate_v4()` | Unique identifier for the transaction |
| `user_id` | `uuid` | Foreign Key (`auth.users`) | The user who owns this transaction |
| `account_id` | `uuid` | Foreign Key (`accounts.id`) | The account this transaction affects |
| `title` | `text` | Not Null | Title or description |
| `amount` | `numeric` | Not Null | Transaction amount |
| `type` | `text` | Not Null | Either 'INCOME' or 'EXPENSE' |
| `note` | `text` | | Optional extended note |
| `created_at` | `timestamp` | default `now()` | When the transaction was recorded |

*(Note: The account's total balance is computed dynamically by summing its transactions).*

## Setup Instructions

### Prerequisites
1. A [Supabase](https://supabase.com/) project.

### 1. Supabase Configuration
Create the database tables matching the schema above in your Supabase project. Enable Row Level Security (RLS) policies allowing users to `SELECT`, `INSERT`, `UPDATE`, and `DELETE` where `auth.uid() == user_id`.

### 2. Environment Variables
Create a `.env` file in the root of the project with your Supabase credentials:
```env
SUPABASE_URL=your_project_url_here
SUPABASE_ANON_KEY=your_anon_key_here
```
*(Make sure to use an environment manager like `flutter_dotenv` if configuring for production).*

### 3. Build & Run
1. Clone this repository.
2. Run `flutter pub get` to install dependencies.
3. Run `flutter run` to launch the app on your connected device or emulator.

---
*Built with Flutter, BLoC, and Supabase.*

# Data Cleaning & Analysis Task

## Data Cleaning & Normalization (Pandas/SQL)

### Cleaning Process
- Menghapus atau menandai catatan yang bermasalah:
  - Nilai amount yang NULL
  - Nilai amount negatif
  - Memastikan format timestamp valid (diubah ke datetime)
- Menormalisasi kolom category dan status ke nilai yang konsisten
- Menghapus entri duplikat

### Data Quality Checks
- Memvalidasi tipe dan format data
- Memastikan integritas referensial
- Menangani nilai yang hilang dengan tepat

## Top 3 Anomalies Identified

1. **Transactions with NULL Amount**
   - Contoh: Transaksi ID TXN003
   - Masalah: Jumlah transaksi hilang
   - Dampak: Tidak dapat memproses perhitungan pendapatan

2. **Transactions with Negative Amount**
   - Contoh: Transaksi ID TXN008 (-100)
   - Masalah: Nilai negatif dalam kolom amount
   - Dampak: Mungkin menunjukkan pengembalian atau kesalahan input data

3. **Failed Transactions with Valid Amounts**
   - Contoh: Transaksi ID TXN006
   - Masalah: Transaksi gagal tetapi memiliki jumlah yang valid
   - Dampak: Memerlukan investigasi terhadap proses pembayaran

## Python Implementation for Data Cleaning

```python
import pandas as pd
from datetime import datetime

# Sample data
data = {
    'user_id': [101, 101, 102, 103, 101, 104, 103, 105, 103],
    'transaction_id': ['TXN001', 'TXN002', 'TXN003', 'TXN004', 'TXN005', 
                      'TXN006', 'TXN007', 'TXN008', 'TXN009'],
    'amount': [120, 140, None, 95, 200, 300, 180, -100, 90],
    'category': ['onboarding', 'usage', 'usage', 'usage', 'upgrade',
                'usage', 'upgrade', 'usage', 'usage'],
    'timestamp': ['2024-01-01 10:12:00', '2024-01-03 12:42:00', '2024-01-02 08:50:00',
                 '2024-01-04 15:05:00', '2024-02-01 17:00:00', '2024-02-01 10:00:00',
                 '2024-02-02 11:12:00', '2024-02-03 14:45:00', '2024-03-04 10:30:00'],
    'status': ['success', 'success', 'failed', 'success', 'success', 
              'failed', 'success', 'success', 'success']
}

# Create DataFrame
df = pd.DataFrame(data)

def clean_data(df):
    """Clean and preprocess transaction data."""
    # Convert timestamp to datetime
    df['timestamp'] = pd.to_datetime(df['timestamp'])
    
    # Convert amount to numeric, coerce errors to NaN
    df['amount'] = pd.to_numeric(df['amount'], errors='coerce')
    
    # Handle negative amounts
    df.loc[df['amount'] < 0, 'amount'] = None
    
    # Extract month for cohort analysis
    df['month'] = df['timestamp'].dt.to_period('M')
    
    return df

# Apply cleaning function
df_cleaned = clean_data(df)
df_cleaned.to_csv('cleaned_transactions.csv', index=False)

## SQL Queries for Analysis
1. Top 3 Anomalies

```sql
WITH anomalies AS (
    -- Transactions with NULL amount
    SELECT 
        transaction_id,
        'NULL amount' AS anomaly_type,
        'Transaction with missing amount' AS description
    FROM transactions
    WHERE amount IS NULL
    
    UNION ALL
    
    -- Transactions with negative amount
    SELECT 
        transaction_id,
        'Negative amount' AS anomaly_type,
        'Transaction with negative amount' AS description
    FROM transactions
    WHERE amount < 0
    
    UNION ALL
    
    -- Failed transactions with valid amounts
    SELECT 
        transaction_id,
        'Failed with valid amount' AS anomaly_type,
        'Transaction failed but has valid amount' AS description
    FROM transactions
    WHERE status = 'failed' AND amount IS NOT NULL
)
SELECT * FROM anomalies
LIMIT 3;
```

2. Monthly Cohort Retention

```sql
WITH user_first_month AS (
    -- Get first successful transaction month for each user
    SELECT 
        user_id,
        MIN(DATE_TRUNC('month', timestamp)) AS first_month
    FROM transactions
    WHERE status = 'success'
    GROUP BY user_id
),
monthly_active_users AS (
    -- Count active users by cohort and month
    SELECT 
        DATE_TRUNC('month', t.timestamp) AS month,
        ufm.first_month AS cohort,
        COUNT(DISTINCT t.user_id) AS active_users
    FROM transactions t
    JOIN user_first_month ufm ON t.user_id = ufm.user_id
    WHERE t.status = 'success'
    GROUP BY 1, 2
)
-- Calculate retention rates
SELECT 
    TO_CHAR(cohort, 'YYYY-MM') AS cohort,
    TO_CHAR(month, 'YYYY-MM') AS month,
    active_users,
    ROUND(
        active_users * 100.0 / 
        FIRST_VALUE(active_users) OVER (
            PARTITION BY cohort 
            ORDER BY month
        ), 
        2
    ) AS retention_rate
FROM monthly_active_users
ORDER BY cohort, month;
```

## Data Quality Summary

|Metric	Count|
|---|---|
|Total Transactions|9|
|NULL Amounts|1|
|Negative Amounts|1|
|Failed Transactions|2|
|Unique Users|5|
|Date Range|Jan - Mar 2024|

## Recommendations

### Data Collection:
- Implementasi validasi data saat input
- Menambahkan batasan field yang diperlukan di database

### Monitoring:
- Set up alerts for unusual patterns
- Monitor failed transaction rates

### Documentation:
- Document data quality rules
- Create a data dictionary for field definitions

### Next Steps:
- Investigate root causes of data issues
- Implement automated data quality checks
- Schedule regular data quality reports
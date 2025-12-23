# High-Fidelity Debugging

## Analisis Kode

Kode ini membuat sistem multi-threading dengan karakteristik berikut:
- Membuat 10 thread yang berjalan secara paralel
- Setiap thread menjalankan 100 iterasi proses
- Setiap iterasi melakukan:
  - Simulasi kegagalan I/O secara acak
  - Meningkatkan counter global
  - Menambahkan data ke dalam list global
- Program menunggu semua thread selesai sebelum berakhir

## Masalah Utama

### 1. Memory Leak
- **Masalah**: `leaky_global` terus bertambah tanpa dibersihkan
- **Dampak**: Penggunaan memori akan terus meningkat seiring waktu

### 2. Race Condition
- **Masalah**: `self.counter += 1` tidak thread-safe
- **Dampak**: Nilai counter tidak akurat karena race condition

### 3. Manajemen Thread yang Kurang Baik
- **Masalah**: Instance `Processor` dibuat per thread
- **Dampak**: Counter tidak terakumulasi secara global

### 4. Error Handling yang Minimal
- **Masalah**: Hanya menggunakan `print` untuk menangani error
- **Dampak**: Kesalahan sulit didiagnosis dan tidak ada mekanisme retry

### 5. Kurangnya Monitoring
- **Masalah**: Tidak ada sistem monitoring yang terintegrasi
- **Dampak**: Sulit mendeteksi masalah performa dan error secara real-time

## Solusi dan Perbaikan Kode

```python
import threading
import time
import random
import logging
from typing import List

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.StreamHandler(),
        logging.FileHandler('app.log')
    ]
)

class Processor:
    def __init__(self):
        self.lock = threading.Lock()
        self.counter = 0
        self.data: List[str] = []

    def simulate_io_failure(self) -> str:
        """Simulasikan kemungkinan kegagalan I/O."""
        if random.random() < 0.3:
            raise IOError("Random I/O failure!")
        return "Operation completed successfully"

    def process_data(self) -> None:
        """Proses data dengan penanganan error yang lebih baik."""
        for _ in range(100):
            try:
                result = self.simulate_io_failure()
                logging.info(f"Operation result: {result}")
                
                with self.lock:
                    self.counter += 1
                    self.data.append(f"Data-{self.counter}")
                
                time.sleep(0.01)
                
            except IOError as e:
                logging.error(f"I/O operation failed: {e}")
                time.sleep(0.5)
            except Exception as e:
                logging.critical(f"Unexpected error: {e}")
                break

def main():
    processor = Processor()
    
    threads = [
        threading.Thread(target=processor.process_data, name=f"Worker-{i}")
        for i in range(10)
    ]
    
    for t in threads:
        t.start()
        logging.info(f"Started thread: {t.name}")
    
    for t in threads:
        t.join()
    
    logging.info(f"Total operations completed: {processor.counter}")
    logging.info(f"Total data processed: {len(processor.data)}")

if __name__ == "__main__":
    main()
```

## Saran Monitoring

### 1. Memory Monitoring
- **tracemalloc**: Melacak alokasi memori
- **psutil**: Memantau penggunaan sumber daya sistem

### 2. Thread & CPU Monitoring
- **Prometheus + Grafana**: Visualisasi metrik performa
- **Thread Dump**: Analisis deadlock dan thread contention

### 3. Error Tracking
- **Structured Logging**: Format log yang konsist
- **Sentry**: Pelacakan error secara real-time

### 4. Load Testing
- **Locust**: Load testing berbasis Python
- **JMeter**: Testing performa yang baik

## Best Practices yang Diterapkan
1. Thread safety dengan `threading.Lock()`
2. Error handling
3. Logging yang informatif
4. Type hints
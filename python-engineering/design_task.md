# Pluggable Data Validator with Strategy Pattern

## Overview
Untuk memenuhi kebutuhan validasi CSV, JSON, dan XML yang mudah diperluas, digunakan pendekatan pluggable validator dengan pola desain strategy. Setiap format memiliki validator sendiri yang bertanggung jawab melakukan parsing dan validasi schema.

## Desain Arsitektur

### Strategy Pattern
Kami menggunakan Strategy Pattern untuk memisahkan logika validasi dari kode utama.

### Base Validator Interface
```python
from abc import ABC, abstractmethod

class Validator(ABC):
    @abstractmethod
    def parse(self, raw):
        """Parse raw data into Python objects"""
        pass

    @abstractmethod
    def validate(self, data, schema):
        """Validate data against the given schema"""
        pass
```

### Schema Definition
```python
SCHEMA = {
    "id": int,
    "name": str,
    "age": int
}
```

## Implementasi Validator

### 1. CSV Validator
```python
import csv
from io import StringIO

class CSVValidator(Validator):
    def parse(self, raw):
        reader = csv.DictReader(StringIO(raw))
        return list(reader)

    def validate(self, data, schema):
        errors = []
        for i, row in enumerate(data, start=1):
            for field, ftype in schema.items():
                if field not in row:
                    errors.append(f"Row {i}: field '{field}' tidak ada")
                else:
                    try:
                        ftype(row[field])
                    except:
                        errors.append(f"Row {i}: {field} harus {ftype.__name__}")
        return errors
```

### 2. JSON Validator
```python
import json

class JSONValidator(Validator):
    def parse(self, raw):
        return json.loads(raw)

    def validate(self, data, schema):
        errors = []
        for i, item in enumerate(data, start=1):
            for field, ftype in schema.items():
                if field not in item:
                    errors.append(f"Index {i}: field '{field}' tidak ada")
                elif not isinstance(item[field], ftype):
                    errors.append(f"Index {i}: {field} harus {ftype.__name__}")
        return errors
```

### 3. XML Validator
```python
import xml.etree.ElementTree as ET

class XMLValidator(Validator):
    def parse(self, raw):
        root = ET.fromstring(raw)
        data = []
        for person in root.findall('person'):
            record = {child.tag: child.text for child in person}
            data.append(record)
        return data

    def validate(self, data, schema):
        errors = []
        for i, item in enumerate(data, start=1):
            for field, ftype in schema.items():
                if field not in item:
                    errors.append(f"Node {i}: field '{field}' tidak ada")
                else:
                    try:
                        ftype(item[field])
                    except:
                        errors.append(f"Node {i}: {field} harus {ftype.__name__}")
        return errors
```

## Validator Registry (Pluggable)
```python
VALIDATORS = {
    "csv": CSVValidator(),
    "json": JSONValidator(),
    "xml": XMLValidator()
}

def validate_file(file_type, raw_data, schema):
    """
    Validate file data against schema
    
    Args:
        file_type: Type of file ('csv', 'json', 'xml')
        raw_data: Raw file content as string
        schema: Validation schema
        
    Returns:
        list: List of validation errors, empty if valid
    """
    validator = VALIDATORS[file_type]
    parsed = validator.parse(raw_data)
    return validator.validate(parsed, schema)
```

## Fitur Validasi

### Yang Dilakukan
- Parsing data sesuai format
- Memastikan setiap field (id, name, age) tersedia
- Memastikan tipe data sesuai schema (id:int, name:str, age:int)
- Mencatat error detail, contoh:
  - `Row 2: age harus bertipe int`
  - `Index 3: field 'name' tidak ada`
  - `Node 1: id harus int`

## Keunggulan Desain

### 1. Extensibility
- Mudah menambah format baru (cukup buat class validator baru)
- Registrasi validator yang sederhana

### 2. Maintainability
- Kode terpisah dan tidak saling bergantung
- Setiap validator fokus pada satu format

### 3. Testability
- Mudah diuji secara terpisah
- Mocking menjadi lebih sederhana

### 4. Single Responsibility
- Setiap class hanya memiliki satu alasan untuk berubah
- Pemisahan yang jelas antara parsing dan validasi

    
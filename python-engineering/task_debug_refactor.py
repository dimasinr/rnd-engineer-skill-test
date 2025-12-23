def process_data(records):
    result = []
    for i in range(len(records)):
        if i > 0 and records[i]['timestamp'] - records[i-1]['timestamp'] < 100:
            continue
        if 'value' not in records[i] or records[i]['value'] is None:
            continue
        result.append((records[i]['id'], records[i]['value']**2))
    return sorted(result, key=lambda x: x[1], reverse=True)


# Fungsi tersebut memproses daftar data dengan cara melewati record 
# yang memiliki selisih timestamp kurang dari 100 dibanding data sebelumnya 
# atau tidak memiliki field value (atau bernilai None). Untuk data yang valid,
# fungsi akan mengambil id, mengkuadratkan nilai value, lalu menyimpannya 
# dalam bentuk tuple (id, value²). Setelah semua data diproses, hasilnya 
# diurutkan berdasarkan nilai kuadrat value secara desc dan 
# dikembalikan sebagai list terurut. 

##################### REFACTOR CODE #######################

def process_data(records):
    result = []
    for prev, curr in zip([None] + records[:-1], records):
        if prev and curr['timestamp'] - prev['timestamp'] < 100:
            continue
        if curr.get('value') is None:
            continue
        result.append((curr['id'], curr['value'] ** 2))

    return sorted(result, key=lambda x: x[1], reverse=True)

# Struktur loop lebih bersih, jadi gampang menambah validasi atau aturan baru ke depannya.

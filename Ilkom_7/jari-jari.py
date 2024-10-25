import math

def hitung_lingkaran():
    # Meminta pengguna memasukkan jari-jari lingkaran
    jari_jari = float(input("Masukkan jari-jari lingkaran: "))
    
    # Menghitung luas dan keliling lingkaran
    luas = math.pi * jari_jari ** 2
    keliling = 2 * math.pi * jari_jari
    
    # Menampilkan hasil perhitungan
    print(f"Luas lingkaran: {luas:.2f}")
    print(f"Keliling lingkaran: {keliling:.2f}")

# Memanggil fungsi
hitung_lingkaran()

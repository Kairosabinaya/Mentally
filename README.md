## 🗄️ Firestore Structure

### Collection: `users`

Saat registrasi, data user akan disimpan di koleksi `users` dengan struktur dokumen seperti berikut:

| Field        | Type    | Description                              |
|--------------|---------|------------------------------------------|
| uid          | string  | UID dari Firebase Authentication         |
| name         | string  | Nama lengkap pengguna                    |
| email        | string  | Alamat email pengguna                    |
| password     | string  | Password User                            |
| createdAt    | string  | Tanggal dan waktu pembuatan akun (ISO)   |

> 📌 Catatan:
> - Auth disimpan di **Firebase Authentication**, bukan di Firestore.
> - Firestore hanya menyimpan profil tambahan seperti `name` dan `createdAt`.

Contoh dokumen `users/uid123`:
```json
{
  "uid": "uid123",
  "name": "John Doe",
  "email": "john@example.com",
  "role": "user",
  "createdAt": "2025-06-09T08:10:00.000Z"
}
```

import tkinter as tk
from PIL import Image, ImageTk

# Tạo cửa sổ
window = tk.Tk()
window.title("Giới thiệu thành viên nhóm")
window.geometry("600x300")

# Danh sách thành viên
members = [
    ("Nguyễn Thế Dũng", "dung.jpg"),
    ("Trần Tùng Dương", "duong.jpg"),
    ("Lê Văn Sáng", "sang.jpg")
]

# Hiển thị tiêu đề
title = tk.Label(window, text="Giới thiệu thành viên nhóm", font=("Arial", 18))
title.pack(pady=10)

# Frame chứa thành viên
frame = tk.Frame(window)
frame.pack()

# Hiển thị từng thành viên
for name, img_path in members:
    sub_frame = tk.Frame(frame)
    sub_frame.pack(side=tk.LEFT, padx=20)

    image = Image.open(img_path)
    image = image.resize((120, 120))
    photo = ImageTk.PhotoImage(image)

    label_img = tk.Label(sub_frame, image=photo)
    label_img.image = photo
    label_img.pack()

    label_name = tk.Label(sub_frame, text=name, font=("Arial", 12))
    label_name.pack()

# Chạy chương trình
window.mainloop()
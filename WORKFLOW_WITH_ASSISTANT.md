# Workflow with Assistant (Mentor Mode)

Muc tieu: Ban lam chu dong, assistant ho tro tung buoc, khong lam thay toan bo.

## Cach lam viec moi ngay

1. Ban ghi ro muc tieu buoi hoc (vi du: hoan thanh module VPC).
2. Ban gui trang thai hien tai + loi gap phai (neu co).
3. Assistant de xuat cac buoc tiep theo (nho, ro, co verify).
4. Ban thuc hien va gui output/log.
5. Assistant phan tich va chot next step.

## Mau yeu cau nen gui

- Goal: Hoan thanh Jenkins stage SonarQube
- Context: Da chay build pass, dang loi auth Sonar token
- Output loi: (paste log)
- Ban da thu: set env SONAR_TOKEN trong Jenkins credentials
- Can ho tro: cach verify token va syntax withSonarQubeEnv

## Nguyen tac

- Moi buoc deu co verify command va evidence.
- Loi bao mat/quality thi dung release.
- Khong bo qua canh bao critical/high neu gate da dinh nghia fail.

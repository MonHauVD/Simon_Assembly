; Tro choi tri nho Simon

.model small
.stack 100h

Random macro rand
    ; generate a rand no using the system time
   
   MOV AH, 00h  ; interrupts to get system time        
   INT 1AH      ; CX:DX now hold number of clock ticks since midnight      

   mov  ax, dx
   xor  dx, dx
   mov  cx, 10    
   div  cx       ; here dx contains the remainder of the division - from 0 to 9

   mov rand, dl
   endm    
.code

InDiem macro Diem
    mov ah,02h  ; dat con tro
    mov dh,0    ; dong
    mov dl,0   ; cot
    mov bh,0
    int 10h
    
    mov ah,09
    mov dx, offset msg_Diem
    int 21h
    
    mov ax, 0
    mov al, diem
    call outputDec    
    endm

main proc
    mov ax, @data
    mov ds, ax

; Man hinh chinh va huong dan
    mov ah,0h
    mov al,03h
    int 10h
    
    mov ah,02h  ; dat con tro
    mov dh,3    ; dong
    mov dl,28   ; cot
    mov bh,0
    int 10h
    mov ah,09   ; In chuoi den khi tim thay $
    mov dx, offset msg_TieuDe
    int 21h
    
    mov ah,02h
    mov dh,6
    mov dl,10
    mov bh,0
    int 10h
    mov ah,09
    mov dx, offset msg_Huong_dan
    int 21h
    
    mov ah,02h
    mov dh,9
    mov dl,10
    mov bh,0
    int 10h
    mov ah,09
    mov dx, offset msg_Phim
    int 21h
    
    mov si, offset msg_Color ; Vong lap hien thi phim
    mov cx, 10
    Trinh_dien_Phim:
        mov ah,02h
        mov dh,cl   ; duong
        mov dl,14   ; cot
        mov bh,0
        int 10h
    
        xor ax,ax
        mov ah,09h
        mov dx, [si]
        int 21h
    
        add si,2
        inc cx            ; Bat dau o hang 10 them 1 moi chu ki
        cmp cl,15         ; Kiem tra xem con thieu ko (10 + 5 = 15 phim)
        jne Trinh_dien_Phim
    
    call MucDoKho
            
    
    mov ah,02h
    mov dh,21
    mov dl,18
    mov bh,0
    int 10h
    mov ah,09
    mov dx, offset msg_Enter_de_bat_dau
    int 21h
    
    
    Doi_nhan_phim_Enter:           ; doi cho den khi ban nhan phim enter
    mov ah,00h
    int 16h
    cmp al, 0dh
    jne Doi_nhan_phim_Enter
    
    ; Bat dau tro choi
    Bat_dau_tro_choi:
    
    Random rand          ; Lay ma ngau nhien
 
    mov ax,1003h         ; Che do hien thi de huy nhap nhay
    mov bx,0
    int 10h
    
    mov ah,6             ; Xoa man hinh
    xor al,al
    xor cx,cx
    mov dx,184fh
    mov bh,13
    int 10h
 

    mov ch,32            ; An con tro
    mov ah,1
    int 10h
    
    call Xanh_la_dam    ; Ve cac o mau
    call Do_sam
    call Xanh_lam_dam
    call Vang
    
    ; Chu ky tro choi
    TroChoi:                    ; Chu ky kiem soat su lap lai cua trinh tu va nhan phim
        InDiem Diem
        Mov al, Diem
        Inc al
        Mov Diem, al
        
        inc pass              ; Bo dem chu ky de tai tao chuoi den so cuoi cung
        call Lay_chuoi_random    ; Si tro den mot mang co trinh tu
        mov cx, 0
        Trinh_dien:                 ; Vong lap de hien thi trinh tu
            mov al,[si]
            call Nhan_phim_Hien_mau        ; Thu tuc ve va choi mot ghi chu
            inc si               ; Luu y tiep theo
            inc cx
            cmp cx,pass        ; Neu bo dem van ko dat dc so lan vuot qua, no se phat nhu sau
            jb Trinh_dien
    
        call Lay_chuoi_random
        mov cx,0                 ; chu ki de nhap day phim
        Nhan_phim:
            push cx
    
            mov ah,07h           ; cho bam phim
            int 21h              ; Tra ve phim
    
            call Nhan_phim_Hien_mau
    
            cmp al,1bh           ; Bam ESC de thoat 
            jne noESC
            jmp Thoat
            noESC:
    
            cmp al,[si]          ; So sanh phim bam voi ki tu trong mang
            jne Sai              ; Neu khac -> ket thuc
            inc si               ; Neu giong -> tiep tuc (tang si)
    
            pop cx
            inc cx
            cmp cx,pass       ; Lap lai chu trinh de nhan phim tiep theo
            jb Nhan_phim
    
    
            cmp [si],'$'         ; Neu den cuoi day
            je Thang_cuoc         ; Ket thuc tro choi va in man hinh thang cuoc
            jmp TroChoi            ; Neu khong thi tiep tuc choi den khi het
    
    
    Sai:                  ;  Hien thi thong bao thua cuoc
        mov ah,02h
        mov dh,3    ; hang
        mov dl,36   ; cot
        mov bh,0
        int 10h
    
        mov ah,09
        mov dx, offset msg_Thua
        int 21h
        jmp Thoat
    
    Thang_cuoc:                  ; Hien thi man hinh thang cuoc
        InDiem Diem
        mov ah,02h
        mov dh,3
        mov dl,26
        mov bh,0
        int 10h
    
        mov ah,09
        mov dx, offset msg_Thang
        int 21h
    
    Thoat:
        mov ah,02h
        mov dh,2
        mov dl,20
        mov bh,0
        int 10h
    
        mov ah, 09h             ; Hien thi cam on
        mov dx, offset msg_CamOn
        int 21h
        
        mov ah,02h; Dua con tro
        mov dh,18; dong
        mov dl,20;cot
        mov bh,0
        int 10h
    
        mov ah, 09h             ; Hien thi huong thoat
        mov dx, offset msg_Enter_de_thoat
        int 21h
    
        Doi_phim_Enter:
        mov ah,00h
        int 16h
        cmp al, 0dh
        je  Thoat_kt
        cmp al, 20h
        jne  Doi_phim_Enter
        
        Bat_dau_lai_game:
            Mov ax, 0
            Mov Diem, al
            Mov Pass, ax
            
            mov ah,6             ; Xoa man hinh
            xor al,al
            xor cx,cx
            mov dx,184fh
            mov bh,7h
            int 10h
            
            Call MucDoKho
            jmp Bat_dau_tro_choi
        
        Thoat_kt:
        mov ax, 0003h  ; Chuyen cai+u hinh man hinh binh thuong (text 80*25)
        int 10h
        mov ax, 4c00h  ; Tuong duong tra ve 0 trong c de tranh su co trong DOSBox
        int 21h
    
    ; Nhan phim va choi ghi chu cua no
    ; Doi phim 'al'
    proc Nhan_phim_hien_mau
        push ax
    
        cmp al,'q'          ; Mau xanh la
        jne Ko_Xanh_la
        call Xanh_la_sang
        mov bx,5709         ; Tan suat ghi chu
        call play_note
        call Xanh_la_dam
        jmp Phim_duoc_xu_li
        
        Ko_Xanh_la:
    
            cmp al,'w'          ; Mau do
            jne Ko_Do
            call Do_sang
            mov bx,4870
            call play_note
            call Do_sam
            jmp Phim_duoc_xu_li
        Ko_Do:
    
            cmp al,'a'          ; Mau xanh da troi
            jne Ko_Xanh_lam
            call Xanh_lam_sang
            mov bx,2875
            call play_note
            call Xanh_lam_dam
            jmp Phim_duoc_xu_li
        Ko_Xanh_lam:
    
            cmp al,'s'          ; Mau vang
            jne Ko_Vang
            call Trang
            mov bx,3837
            call play_note
            call Vang
            jmp Phim_duoc_xu_li
        Ko_Vang:
            
            
        Phim_duoc_xu_li:
        pop ax
        ret
    endp
    
    proc MucDoKho 
        push ax
        push bx
        push cx
        push dx
        
        mov cx, 0
        mov ah,02h; Bao nhap do kho
        mov dh,15
        mov dl,10
        mov bh,0
        int 10h
        mov ah,09
        mov dx, offset msg_DoKho
        int 21h
        
        Nhap_Do_Kho:   
            mov ah, 1h
            int 21h
            cmp al, '1'
            je Luu_Do_Kho
            cmp al, '2'
            je Luu_Do_Kho
            cmp al, '3'
            je Luu_Do_Kho
        
        Nhap_Do_Kho_loi:
            mov ah,02h; Nhap loi cho muc kho
            mov dh,16
            mov dl,10
            mov bh,0
            int 10h
            mov ah,09
            mov dx, offset msg_DoKhoLoi
            int 21h
            Jmp Nhap_Do_Kho
        
        Luu_Do_Kho:
            Sub al, '0'
            Mov DoKho, al
            mov ah,02h; Bao do kho da nhap
            mov dh,18
            mov dl,10
            mov bh,0
            int 10h
            mov ah,09
            mov dx, offset msg_DoKhoDaNhap
            int 21h
            
            mov al, DoKho
            De:
                cmp al, 1
                jne Vua
                mov ah,09
                mov dx, offset msg_De
                int 21h
                Jmp HetNhapDoKho
            Vua:
                cmp al, 2
                jne Kho
                mov ah,09
                mov dx, offset msg_Vua
                int 21h
                Jmp HetNhapDoKho
            Kho:
                mov ah,09
                mov dx, offset msg_Kho
                int 21h
                Jmp HetNhapDoKho
            HetNhapDoKho:
            
            pop dx
            pop cx
            pop bx
            pop ax    
            ret        
        endp
        ; Phat ghi chu qua loa trong
        ; Doi trong 'bx' tan suat ghi chu
        proc play_note
        
            push cx
            Mov ah, 02
            Mov dl, 7
            int 21h
        
            pop cx
            ret
    endp
    
    proc Lay_chuoi_random
        push ax
        Mov al, DoKho
        De1:
            cmp al, 1
            jne Vua1
            Jmp MucDoDe1
        Vua1:
            cmp al, 2
            jne Kho1
            Jmp MucDoVua1
        Kho1:
            Jmp MucDoKho1
        
        MucDoDe1:    
            Mov al, rand
            ChuoiDe0:
                cmp al, 0
                Jne chuoiDe1
                mov si, offset Chuoi_phim_De_0
                Jmp TraVe
            ChuoiDe1:
                cmp al, 1
                Jne chuoiDe2
                mov si, offset Chuoi_phim_De_1
                Jmp TraVe
            ChuoiDe2:
                cmp al, 2
                Jne chuoiDe3
                mov si, offset Chuoi_phim_De_2
                Jmp TraVe
            ChuoiDe3:
                cmp al, 3
                Jne chuoiDe4
                mov si, offset Chuoi_phim_De_3
                Jmp TraVe
            ChuoiDe4:
                cmp al, 4
                Jne chuoiDe5
                mov si, offset Chuoi_phim_De_4
                Jmp TraVe
            ChuoiDe5:
                cmp al, 5
                Jne chuoiDe6
                mov si, offset Chuoi_phim_De_5
                Jmp TraVe
            ChuoiDe6:
                cmp al, 6
                Jne chuoiDe7
                mov si, offset Chuoi_phim_De_6
                Jmp TraVe
            ChuoiDe7:
                cmp al, 7
                Jne chuoiDe8
                mov si, offset Chuoi_phim_De_7
                Jmp TraVe
            ChuoiDe8:
                cmp al, 8
                Jne chuoiDe9
                mov si, offset Chuoi_phim_De_8
                Jmp TraVe
            ChuoiDe9:
                mov si, offset Chuoi_phim_De_9
                Jmp TraVe
        MucDoVua1:    
            Mov al, rand
            Chuoi0:
                cmp al, 0
                Jne chuoi1
                mov si, offset Chuoi_phim_0
                Jmp TraVe
            Chuoi1:
                cmp al, 1
                Jne chuoi2
                mov si, offset Chuoi_phim_1
                Jmp TraVe
            Chuoi2:
                cmp al, 2
                Jne chuoi3
                mov si, offset Chuoi_phim_2
                Jmp TraVe
            Chuoi3:
                cmp al, 3
                Jne chuoi4
                mov si, offset Chuoi_phim_3
                Jmp TraVe
            Chuoi4:
                cmp al, 4
                Jne chuoi5
                mov si, offset Chuoi_phim_4
                Jmp TraVe
            Chuoi5:
                cmp al, 5
                Jne chuoi6
                mov si, offset Chuoi_phim_5
                Jmp TraVe
            Chuoi6:
                cmp al, 6
                Jne chuoi7
                mov si, offset Chuoi_phim_6
                Jmp TraVe
            Chuoi7:
                cmp al, 7
                Jne chuoi8
                mov si, offset Chuoi_phim_7
                Jmp TraVe
            Chuoi8:
                cmp al, 8
                Jne chuoi9
                mov si, offset Chuoi_phim_8
                Jmp TraVe
            Chuoi9:
                mov si, offset Chuoi_phim_9
                Jmp TraVe
        MucDoKho1:    
            Mov al, rand
            ChuoiKho0:
                cmp al, 0
                Jne ChuoiKho1
                mov si, offset Chuoi_phim_kho_0
                Jmp TraVe
            ChuoiKho1:
                cmp al, 1
                Jne ChuoiKho2
                mov si, offset Chuoi_phim_kho_1
                Jmp TraVe
            ChuoiKho2:
                cmp al, 2
                Jne ChuoiKho3
                mov si, offset Chuoi_phim_kho_2
                Jmp TraVe
            ChuoiKho3:
                cmp al, 3
                Jne ChuoiKho4
                mov si, offset Chuoi_phim_kho_3
                Jmp TraVe
            ChuoiKho4:
                cmp al, 4
                Jne ChuoiKho5
                mov si, offset Chuoi_phim_kho_4
                Jmp TraVe
            ChuoiKho5:
                cmp al, 5
                Jne ChuoiKho6
                mov si, offset Chuoi_phim_kho_5
                Jmp TraVe
            ChuoiKho6:
                cmp al, 6
                Jne ChuoiKho7
                mov si, offset Chuoi_phim_kho_6
                Jmp TraVe
            ChuoiKho7:
                cmp al, 7
                Jne ChuoiKho8
                mov si, offset Chuoi_phim_kho_7
                Jmp TraVe
            ChuoiKho8:
                cmp al, 8
                Jne ChuoiKho9
                mov si, offset Chuoi_phim_kho_8
                Jmp TraVe
            ChuoiKho9:
                mov si, offset Chuoi_phim_kho_9
                Jmp TraVe        
        
        TraVe:
            pop ax    
            ret
    endp
   
    ; Chuong trinh con de lap lai va ve cac dong van ban
    proc Ve_duong
        push cx
        mov cx,5                 ; # dong
        mov bh,0                 ; trang
        mov al,0
        mov bp, offset relleno   ; Ky tu de hien thi
        Ve_Hop:
            push cx
            mov cx,10            ; # nhan vat
            mov ah,13h           ; Tra ve 1 chuoi co thuoc tinh mau
            int 10h
            inc dh
            pop cx
            loop Ve_Hop
        pop cx
        ret
    endp
    
    proc Ve_duong2
        push cx
        mov cx,5                 ; # dong
        mov bh,0                 ; trang
        mov al,0
        mov bp, offset relleno   ; Ky tu de hien thi
        Ve_Hop2:
            push cx
            mov cx,6            ; # nhan vat
            mov ah,13h           ; Tra ve 1 chuoi co thuoc tinh mau
            int 10h
            inc dh
            pop cx
            loop Ve_Hop2
        pop cx
        ret
    endp
    
    ; Chuong trinh con voi cac thuoc tinh khung
    proc Xanh_la_sang
    mov bl,0aah           ; mau
    mov dl,29             ; cot
    mov dh,5              ; hang
    call Ve_duong
    ret
    endp
    
    proc Xanh_la_dam
    mov bl,022h
    mov dl,29
    mov dh,5
    call Ve_duong
    ret
    endp
    
    proc Do_sang
    mov bl,0CCh
    mov dl,41
    mov dh,5
    call Ve_duong2
    ret
    endp
    
    proc Do_sam
    mov bl,044h
    mov dl,41
    mov dh,5
    call Ve_duong2
    ret
    endp
    
    proc Xanh_lam_sang
    mov bl,099h
    mov dl,29
    mov dh,11
    call Ve_duong
    ret
    endp
    
    proc Xanh_lam_dam
    mov bl,011h
    mov dl,29
    mov dh,11
    call Ve_duong
    ret
    endp
    
    proc Vang
    mov bl,0EEh
    mov dl,41
    mov dh,11
    call Ve_duong2
    ret
    endp
    
    proc Trang
    mov bl,0ffh
    mov dl,41
    mov dh,11
    call Ve_duong2
    ret
    endp
    
    outputDec proc
        push bx
        push cx
        push dx
         
        cmp ax, 0   ;   neu ax > 0 tuc la khong phai so am ta doi ra day
        jge doiRaDay
        push ax
        mov dl, '-'
        mov ah, 2
        int 21h
        pop ax
        neg ax  ; ax = -ax
         
        doiRaDay:
            xor cx, cx  ; gan cx = 0
            mov bx, 10  ; so chia la 10
            chia:
                xor dx, dx  ; gan dx = 0
                div bx      ; ax = ax / bx; dx = ax % bx
                push dx
                inc cx
                cmp ax, 0   ; kiem tra xem thuong bang khong chua?
                jne chia    ; neu khong bang thi lai chia
                mov ah, 2
            hien:
                pop dx
                or dl, 30h  ; Tuong duong lenh Add dx, '0' voi dk dx < 10
                int 21h
                loop hien
                 
                pop dx
                pop cx
                pop bx
                ;pop ax
        ret
         
    outputDec endp
.Data
    msg_TieuDe db "Simon la mot tro choi tri nho$"
    msg_Huong_dan db "Nhan cac phim theo trinh tu da cho$"
    msg_Phim db "Phim:$"
    
    msg_XanhLa db "q = Xanh la$"
    msg_Do db "w = Do$"
    msg_Lam db "a = Xanh da troi$"
    msg_Vang db "s = Vang$"
    msg_Thoat db "ESC = Thoat game$"
    msg_Color dw msg_XanhLa, msg_Do, msg_Lam, msg_Vang, msg_Thoat
    
    msg_DoKho db "Xin hay chon do kho. Bam 1: De; Bam 2: Vua; Bam 3: Kho.$"
    msg_DoKhoLoi db "Ban nhap sai cu phap. Vui long chi an 1, 2 hoac 3!$"
    msg_DoKhoDaNhap db "Do kho da chon: $"
    msg_De db "De.$"
    msg_Vua db "Vua.$"
    msg_Kho db "Kho.$"
    
    msg_Enter_de_bat_dau db "Nhan Enter de bat dau$"
    
    msg_Thua db "Ban da thua.$"
    msg_Thang db "Chuc mung! Ban da thang!$"
    msg_CamOn db "Cam on ban da choi tro choi cua nhom 2.$"
    msg_Enter_de_thoat db "Nhan Enter de thoat. Nhan dau Cach de choi lai.$"
    
    msg_Diem db "Diem: $"
    msg_LoiBamPhim db "Phim ban bam khong dung cu phap. Xin hay bam lai!$"
    msg_CuPhap db "Ban chi duoc bam cac phim q, w, a, s de choi tiep. Hoac bam phim Enter de thoat.$"
    
    relleno db "12345678901234567890"
    chuoi_phim_De_0 db 'qqwsqw$'
    chuoi_phim_De_1 db 'awqqwa$'
    chuoi_phim_De_2 db 'qwawsa$'
    chuoi_phim_De_3 db 'awqsaa$'
    chuoi_phim_De_4 db 'asqssq$'
    chuoi_phim_De_5 db 'wwqsqw$'
    chuoi_phim_De_6 db 'saqwsa$'
    chuoi_phim_De_7 db 'wqsqws$'
    chuoi_phim_De_8 db 'asqqaq$'
    chuoi_phim_De_9 db 'qaswsq$'
    chuoi_phim_0 db 'qqwwssaawqsa$'
    chuoi_phim_1 db 'qwasqawasasa$'
    chuoi_phim_2 db 'wsaqswaqswaq$'
    chuoi_phim_3 db 'aaaqasswqaww$'
    chuoi_phim_4 db 'sssqqwwaqqsa$'
    chuoi_phim_5 db 'sqasqwaqwsaq$'
    chuoi_phim_6 db 'awsqasaaqqws$'
    chuoi_phim_7 db 'sqawqawsaqsw$'
    chuoi_phim_8 db 'awsqawsaqwsq$'
    chuoi_phim_9 db 'qwsawsqaawwq$'
    chuoi_phim_Kho_0 db 'qqwwssaawqsawqsawa$'
    chuoi_phim_Kho_1 db 'qwasqawasasaqwsawq$'
    chuoi_phim_Kho_2 db 'wsaqswaqswaqwsaqws$'
    chuoi_phim_Kho_3 db 'aaaswqaswqasswqaww$'
    chuoi_phim_Kho_4 db 'ssqwasqwsqqwwaqqsa$'
    chuoi_phim_Kho_5 db 'sqwqwqwqasqwaqwsaq$'
    chuoi_phim_Kho_6 db 'wsaqwsawsqasaaqqws$'
    chuoi_phim_Kho_7 db 'qwsaawsqawqawsaqsw$'
    chuoi_phim_Kho_8 db 'qaqswqawsqawsaqwsq$'
    chuoi_phim_Kho_9 db 'qsqwsaqwsawsqaawwq$'
    pass dw 0
    rand db ?
    Diem db 0
    Mau db ?
    DoKho db ?

end main
;Code made by Viet Dung


;The formula to choose color goes like this:

;text-background * 16 + text-color

;Next are the colors :

;Black         =  0
;Blue          =  1
;Green         =  2
;Cyan          =  3
;Red           =  4
;Magenta       =  5
;Brown         =  6
;LightGray     =  7
;DarkGray      =  8
;LightBlue     =  9
;LightGreen    = 10
;LightCyan     = 11
;LightRed      = 12
;LightMagenta  = 13
;Yellow        = 14
;White         = 15
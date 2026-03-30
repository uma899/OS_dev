global reboot
reboot:
    ; Creating a "Null" IDT pointer (length = 0)
    push 0
    push 0
    lidt [esp]          ; The CPU now has no handlers.

    int 3               ; This causes a 'Triple Fault'. So reboots... Just a way to rebooot!

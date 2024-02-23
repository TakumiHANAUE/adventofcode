
## Input Example : `?? 1`

getArrangements(position: 0, group: 0, size: 0)
```
character      : ? ?
state.position : ^
```
- When `#` : getArrangements(position: 1, group: 0, size: 1)
    ```
    character      : # ?
    state.position :   ^
    ```
    - When `#` : no need to call getArrangements()  
        because the processing size is already reaches the considering size(=1)
    - When `.` : getArrangements(position: 2, group: 1, size: 0)
        ```
        character      : # .
        state.position :     ^
        ```
        return 1
- When `.` : getArrangements(position: 1, group: 0, size: 0)
    ```
    character      : . ?
    state.position :   ^
    ```
    - When `#` : getArrangements(position: 2, group: 0, size: 1)
        ```
        character      : . #
        state.position :     ^
        ```
        return 1
    - When `.` : getArrangements(position: 2, group: 0, size: 0)  
        wrong arrangement
        ```
        character      : . .
        state.position :     ^
        ```
        return 0

# 1 "validation/two_core/omp_twocore_test.c"
# 1 "<built-in>"
# 1 "<command-line>"
# 1 "validation/two_core/omp_twocore_test.c"
# 1 "/home/sharon/sparc-elf_i386_OpenMP_support/Openmp/omp.h" 1



# 1 "/home/sharon/sparc-elf_i386_OpenMP_support/Openmp/parallel_runtime.h" 1



typedef void (*parallel_function)(void *);

enum parallel_error {
    PARALLEL_BAD_CORE = 1,
    PARALLEL_BAD_TEAM,
    PARALLEL_NESTED_REGION,
    PARALLEL_BAD_STATE,
    PARALLEL_BAD_FUNCTION
};


void parallel_runtime_init(void);





void parallel_worker_loop(void);






void parallel_runtime_shutdown(void);


extern volatile unsigned int parallel_runtime_error;


void GOMP_parallel_start(parallel_function function,
                         void *argument,
                         unsigned int num_threads);

void GOMP_barrier(void);


void GOMP_atomic_start(void);
void GOMP_atomic_end(void);


void GOMP_critical_start(void);
void GOMP_critical_end(void);

void GOMP_parallel_end(void);
# 5 "/home/sharon/sparc-elf_i386_OpenMP_support/Openmp/omp.h" 2
# 1 "/home/sharon/sparc-elf_i386_OpenMP_support/Openmp/board_exit.h" 1



void board_terminate(unsigned int status) __attribute__((noreturn));
# 6 "/home/sharon/sparc-elf_i386_OpenMP_support/Openmp/omp.h" 2



# 1 "/home/sharon/sparc-elf_i386_OpenMP_support/Openmp/parallel_platform.h" 1







# 1 "/home/sharon/sparc-elf_i386_OpenMP_support/Openmp/sparcv8_tso.h" 1



# 1 "/home/sharon/sparc-elf_i386_OpenMP_support/.boards/profile.aAV8fmKP/board_config.h" 1
# 5 "/home/sharon/sparc-elf_i386_OpenMP_support/Openmp/sparcv8_tso.h" 2

static inline unsigned int platform_core_id(void)
{
    unsigned int value;

    __asm__ __volatile__(
        "rd %%asr" "29" ", %0"
        : "=r"(value)
    );

    return (value >> 8) & 0xffu;
}


static inline unsigned int
state_load_acquire(const unsigned int *address)
{
    unsigned int value;

    __asm__ __volatile__(
        "ld [%1], %0"
        : "=r"(value)
        : "r"(address)
        : "memory"
    );

    return value;
}

static inline void
state_store_release(unsigned int *address, unsigned int value)
{
    __asm__ __volatile__(
        "st %0, [%1]"
        :
        : "r"(value), "r"(address)
        : "memory"
    );
}


static inline unsigned int
platform_lock_try(unsigned char *lock)
{
    unsigned int previous;

    __asm__ __volatile__(
        "ldstub [%1], %0"
        : "=r"(previous)
        : "r"(lock)
        : "memory"
    );

    return previous == 0;
}

static inline void
platform_lock_acquire(unsigned char *lock)
{
    while (!platform_lock_try(lock)) {

    }
}

static inline void
platform_lock_release(unsigned char *lock)
{
    __asm__ __volatile__(
        "stb %%g0, [%0]"
        :
        : "r"(lock)
        : "memory"
    );
}

static inline void platform_runtime_fail(unsigned int error)
{

    (void)error;
    board_terminate(0);
}
# 9 "/home/sharon/sparc-elf_i386_OpenMP_support/Openmp/parallel_platform.h" 2
# 10 "/home/sharon/sparc-elf_i386_OpenMP_support/Openmp/omp.h" 2



int omp_get_thread_num(void);
int omp_get_num_threads(void);
# 2 "validation/two_core/omp_twocore_test.c" 2
# 1 "/home/sharon/SparcV8_core/compiler/include/ajit_mt_irc.h" 1
# 33 "/home/sharon/SparcV8_core/compiler/include/ajit_mt_irc.h"
# 1 "/home/sharon/SparcV8_core/compiler/include/stdint.h" 1
# 14 "/home/sharon/SparcV8_core/compiler/include/stdint.h"
typedef signed char int8_t;
typedef unsigned char uint8_t;
typedef short int16_t;
typedef unsigned short uint16_t;
typedef int int32_t;
typedef unsigned int uint32_t;
typedef long long int64_t;
typedef unsigned long long uint64_t;

typedef int intptr_t;
typedef unsigned int uintptr_t;
# 34 "/home/sharon/SparcV8_core/compiler/include/ajit_mt_irc.h" 2
# 1 "/home/sharon/SparcV8_core/compiler/include/device_addresses.h" 1
# 35 "/home/sharon/SparcV8_core/compiler/include/ajit_mt_irc.h" 2
# 1 "/home/sharon/SparcV8_core/compiler/include/ajit_access_routines.h" 1
# 33 "/home/sharon/SparcV8_core/compiler/include/ajit_access_routines.h"
static inline void __ajit_store_word_mmu_bypass__(uint32_t value, uint32_t addr)
{
 __asm__ __volatile__("sta %0, [%1] %2" : : "r"(value), "r"(addr), "i"(0x20) : "memory");
}

static inline uint32_t __ajit_load_word_mmu_bypass__(uint32_t addr)
{
 uint32_t value;
 __asm__ __volatile__("lda [%1] %2, %0" : "=r"(value) : "r"(addr), "i"(0x20) : "memory");
 return value;
}


static inline void __ajit_store_ubyte_mmu_bypass__(uint8_t value, uint32_t addr)
{
 __asm__ __volatile__("stba %0, [%1] %2" : : "r"(value), "r"(addr), "i"(0x20) : "memory");
}

static inline uint8_t __ajit_load_ubyte_mmu_bypass__(uint32_t addr)
{
 uint32_t value;
 __asm__ __volatile__("lduba [%1] %2, %0" : "=r"(value) : "r"(addr), "i"(0x20) : "memory");
 return (uint8_t) value;
}






static inline uint32_t __ajit_read_core_thread_id_word__(void)
{
 uint32_t value;
 __asm__ __volatile__("rd %%asr29, %0" : "=r"(value));
 return value;
}

static inline void ajit_get_core_and_thread_id(uint8_t* core_id, uint8_t* thread_id)
{
 uint32_t word = __ajit_read_core_thread_id_word__();
 *core_id = (word >> 8) & 0xff;
 *thread_id = word & 0xff;
}





static inline void __ajit_write_timer_control_register_via_bypass__(uint32_t val)
{
 __ajit_store_word_mmu_bypass__(val, (0xFFFF0000 + 0x3100));
}

static inline uint32_t __ajit_read_timer_control_register_via_bypass__(void)
{
 return __ajit_load_word_mmu_bypass__((0xFFFF0000 + 0x3100));
}
# 102 "/home/sharon/SparcV8_core/compiler/include/ajit_access_routines.h"
static inline void __ajit_write_serial_control_register_via_bypass__(uint32_t val)
{
 __ajit_store_word_mmu_bypass__(val, (0xFFFF0000 + 0x3200));
}

static inline uint32_t __ajit_read_serial_control_register_via_bypass__(void)
{
 return __ajit_load_word_mmu_bypass__((0xFFFF0000 + 0x3200));
}

static inline void __ajit_write_serial_tx_register_via_bypass__(uint8_t val)
{
 __ajit_store_ubyte_mmu_bypass__(val, (0xFFFF0000 + 0x3204));
}


static inline uint8_t __ajit_read_serial_tx_register_via_bypass__(void)
{
 return __ajit_load_ubyte_mmu_bypass__((0xFFFF0000 + 0x3204));
}

static inline uint8_t __ajit_read_serial_rx_register_via_bypass__(void)
{
 return __ajit_load_ubyte_mmu_bypass__((0xFFFF0000 + 0x3208));
}

static inline void __ajit_write_serial_baud_limit_register_via_bypass__(uint32_t bcv)
{
 __ajit_store_word_mmu_bypass__(bcv, (0xFFFF0000 + 0x320c));
}

static inline uint32_t __ajit_read_serial_baud_limit_register_via_bypass__(void)
{
 return __ajit_load_word_mmu_bypass__((0xFFFF0000 + 0x320c));
}

static inline void __ajit_write_serial_baud_frequency_register_via_bypass__(uint32_t bcv)
{
 __ajit_store_word_mmu_bypass__(bcv, (0xFFFF0000 + 0x3210));
}

static inline uint32_t __ajit_read_serial_baud_frequency_register_via_bypass__(void)
{
 return __ajit_load_word_mmu_bypass__((0xFFFF0000 + 0x3210));
}



static inline void __ajit_serial_configure_via_bypass__(uint8_t enable_tx, uint8_t enable_rx, uint8_t enable_intr)
{
 uint32_t cval = __ajit_read_serial_control_register_via_bypass__();
 cval = enable_tx ? (cval | 0x1) : (cval & ~0x1);
 cval = enable_rx ? (cval | 0x2) : (cval & ~0x2);
 cval = enable_intr ? (cval | 0x4) : (cval & ~0x4);
 __ajit_write_serial_control_register_via_bypass__(cval);
}

static inline void __ajit_serial_set_uart_reset_via_bypass__(uint8_t reset_value)
{
 uint32_t cval = __ajit_read_serial_control_register_via_bypass__();
 cval = reset_value ? (cval | 0x20) : (cval & ~0x20);
 __ajit_write_serial_control_register_via_bypass__(cval);
}





static inline void __ajit_serial_set_baudrate_via_bypass__(uint32_t baud_rate, uint32_t clock_frequency)
{
 uint32_t a = 16 * baud_rate, b = clock_frequency;
 while (b != 0) { uint32_t t = a % b; a = b; b = t; }
 uint32_t gcd = a ? a : 1;
 uint32_t baud_frequency = (16 * baud_rate) / gcd;
 uint32_t baud_limit = (clock_frequency / gcd) - baud_frequency;
 __ajit_write_serial_baud_limit_register_via_bypass__(baud_limit);
 __ajit_write_serial_baud_frequency_register_via_bypass__(baud_frequency);
}



static inline int __ajit_serial_putchar_via_bypass__(char c)
{
 uint32_t ctrl = __ajit_read_serial_control_register_via_bypass__();
 if ((ctrl & 0x1) && !(ctrl & 0x8))
 {
  __ajit_write_serial_tx_register_via_bypass__((uint8_t) c);
  return 1;
 }
 return 0;
}



static inline int __ajit_serial_getchar_via_bypass__(void)
{
 while (!(__ajit_read_serial_control_register_via_bypass__() & 0x10))
  ;
 return (char) __ajit_read_serial_rx_register_via_bypass__();
}



static inline void __ajit_serial_puts_via_bypass__(char* s, uint32_t length)
{
 uint32_t i;
 for (i = 0; i < length && s[i] != 0; i++)
  while (!__ajit_serial_putchar_via_bypass__(s[i]))
   ;
}



static inline void __ajit_serial_gets_via_bypass__(char* s, uint32_t length)
{
 uint32_t i;
 for (i = 0; i < length; i++)
 {
  s[i] = (char) __ajit_serial_getchar_via_bypass__();
  if (s[i] == 0)
   break;
 }
}
# 36 "/home/sharon/SparcV8_core/compiler/include/ajit_mt_irc.h" 2

static inline uint32_t ajitInterruptControlRegisterAddress(int core_id, int thread_id)
{
 return (0xFFFF0000 + 0x3000) + 4 * ((2 * core_id) + thread_id);
}

static inline uint32_t readInterruptControlRegister(int core_id, int thread_id)
{
 return __ajit_load_word_mmu_bypass__(ajitInterruptControlRegisterAddress(core_id, thread_id));
}

static inline void writeInterruptControlRegister(int core_id, int thread_id, uint32_t value)
{
 __ajit_store_word_mmu_bypass__(value, ajitInterruptControlRegisterAddress(core_id, thread_id));
}


static inline uint32_t ajitInterruptControlWritableBits(uint32_t value)
{
 return value & 0xffff;
}


static inline void enableInterruptController(int core_id, int thread_id)
{
 uint32_t cv = ajitInterruptControlWritableBits(readInterruptControlRegister(core_id, thread_id));
 writeInterruptControlRegister(core_id, thread_id, cv | 0x1);
}


static inline void disableInterruptController(int core_id, int thread_id)
{
 uint32_t cv = ajitInterruptControlWritableBits(readInterruptControlRegister(core_id, thread_id));
 writeInterruptControlRegister(core_id, thread_id, cv & ~0x1u);
}


static inline void enableInterrupt(int core_id, int thread_id, int interrupt_id)
{
 uint32_t cv = ajitInterruptControlWritableBits(readInterruptControlRegister(core_id, thread_id));
 writeInterruptControlRegister(core_id, thread_id, cv | (1u << interrupt_id));
}


static inline void disableInterrupt(int core_id, int thread_id, int interrupt_id)
{
 uint32_t cv = ajitInterruptControlWritableBits(readInterruptControlRegister(core_id, thread_id));
 writeInterruptControlRegister(core_id, thread_id, cv & ~(1u << interrupt_id));
}


static inline void enableAllInterrupts(int core_id, int thread_id)
{
 uint32_t cv = ajitInterruptControlWritableBits(readInterruptControlRegister(core_id, thread_id));
 writeInterruptControlRegister(core_id, thread_id, cv | 0xfffe);
}


static inline void enableInterruptControllerAndAllInterrupts(int core_id, int thread_id)
{
 writeInterruptControlRegister(core_id, thread_id, 0xffff);
}


static inline void setInterruptMask(int core_id, int thread_id, uint32_t mask)
{
 uint32_t cv = ajitInterruptControlWritableBits(readInterruptControlRegister(core_id, thread_id));
 cv = (cv & 0x1) | (mask & 0xfffe);
 writeInterruptControlRegister(core_id, thread_id, cv);
}





void (*ajit_global_interrupt_handlers[16])(void);

void ajit_initialize_interrupt_handlers_to_null(void)
{
 int i;
 for (i = 0; i < 16; i++)
  ajit_global_interrupt_handlers[i] = 0;
}

void ajit_set_interrupt_handler(uint32_t interrupt_level, void (*handler)(void))
{
 if (interrupt_level < 16)
  ajit_global_interrupt_handlers[interrupt_level] = handler;
}



void ajit_generic_interrupt_handler(uint32_t tbr_value)
{
 uint8_t core_id, thread_id;
 ajit_get_core_and_thread_id(&core_id, &thread_id);
 disableInterruptController(core_id, thread_id);

 int error = 1;
 uint32_t trap_type = (tbr_value >> 4) & 0xff;
 if (trap_type >= 0x11 && trap_type <= 0x1f)
 {
  void (*handler)(void) = ajit_global_interrupt_handlers[trap_type - 0x10];
  if (handler)
  {
   handler();
   error = 0;
  }
 }

 enableInterruptController(core_id, thread_id);

 if (error)
  __asm__ __volatile__("ta 0");
}
# 3 "validation/two_core/omp_twocore_test.c" 2




static unsigned int runtime_ready;
static unsigned int observed_id[2];
static unsigned int observed_size[2];
static unsigned int counter;

static unsigned int run_test(void)
{
    observed_id[0] = 99;
    observed_id[1] = 99;
    observed_size[0] = 0;
    observed_size[1] = 0;
    counter = 0;

#pragma omp parallel num_threads(2)
    {
        int tid = omp_get_thread_num();
        int i;

        if (tid >= 0 && tid < 2) {
            observed_id[tid] = (unsigned int)tid;
            observed_size[tid] =
                (unsigned int)omp_get_num_threads();
        }

        for (i = 0; i < 100; ++i) {
#pragma omp atomic
            counter++;
        }
    }


    return observed_id[0] == 0 &&
           observed_id[1] == 1 &&
           observed_size[0] == 2 &&
           observed_size[1] == 2 &&
           counter == 200;
}

int main(void)
{
    unsigned int id = platform_core_id();
    unsigned int passed;

    if (id == 0) {
        parallel_runtime_init();


        state_store_release(&runtime_ready, 1);

        passed = run_test();

        parallel_runtime_shutdown();


        board_terminate(passed);
    }

    if (id == 1) {
        while (!state_load_acquire(&runtime_ready)) {
        }

        parallel_worker_loop();


        board_terminate(1);
    }


    board_terminate(0);
}

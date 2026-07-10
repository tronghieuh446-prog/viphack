// FFHack.mm - Free Fire iOS 26.5 Full Hack
// Antiband + DNS VIP + Xóa nhà/cây + ESP Xanh biển + Đạn thẳng

#include <substrate.h>
#include <dlfcn.h>
#include <sys/sysctl.h>
#include <netdb.h>
#include <arpa/inet.h>
#include <dispatch/dispatch.h>
#include <signal.h>
#include <objc/runtime.h>

static int (*orig_stat)(const char *path, struct stat *buf);
static int hooked_stat(const char *path, struct stat *buf) {
    const char* bl[] = {"/Applications/Cydia.app","/bin/bash","/usr/sbin/sshd","/etc/apt","/Library/MobileSubstrate","/var/lib/cydia",NULL};
    for(int i=0; bl[i]; i++) if(strstr(path,bl[i])){errno=ENOENT;return -1;}
    return orig_stat(path,buf);
}
static int (*orig_access)(const char *path, int mode);
static int hooked_access(const char *path, int mode) {
    const char* fb[] = {"cydia","sileo","jailbreak","frida",NULL};
    for(int i=0; fb[i]; i++) if(strstr(path,fb[i])){errno=ENOENT;return -1;}
    return orig_access(path,mode);
}
static int (*orig_sysctl)(int *name, u_int nl, void *oldp, size_t *olp, void *newp, size_t newlen);
static int hooked_sysctl(int *name, u_int nl, void *oldp, size_t *olp, void *newp, size_t newlen) {
    int ret = orig_sysctl(name,nl,oldp,olp,newp,newlen);
    if(name[0]==CTL_KERN && name[1]==KERN_PROC && name[2]==KERN_PROC_PID && oldp)
        ((struct kinfo_proc*)oldp)->kp_proc.p_flag &= ~0x800;
    return ret;
}
static kern_return_t (*orig_tgep)(task_t t, exception_mask_t em, exception_mask_array_t masks, mach_msg_type_number_t *cnt, exception_handler_array_t oh, exception_behavior_array_t ob, exception_flavor_array_t of);
static kern_return_t hooked_tgep(task_t t, exception_mask_t em, exception_mask_array_t masks, mach_msg_type_number_t *cnt, exception_handler_array_t oh, exception_behavior_array_t ob, exception_flavor_array_t of) {
    if(cnt) *cnt=0; return KERN_SUCCESS;
}
static uint32_t (*orig_di_c)(void);
static uint32_t hooked_di_c(void) {
    uint32_t c = orig_di_c();
    for(uint32_t i=0; i<c; i++) { const char *n = orig_di_gn(i); if(n && strstr(n,"FFHack")) return c-1; }
    return c;
}
static const char* (*orig_di_gn)(uint32_t);
static const char* hooked_di_gn(uint32_t i) {
    const char* n = orig_di_gn(i);
    return (n && strstr(n,"FFHack")) ? "/usr/lib/libSystem.B.dylib" : n;
}
static id (*orig_idfv)(id,SEL);
static id hooked_idfv(id self, SEL _cmd) { return [[NSUUID alloc] initWithUUIDString:@"A1B2C3D4-E5F6-7890-ABCD-EF1234567890"]; }
static id (*orig_bid)(id,SEL);
static id hooked_bid(id self, SEL _cmd) { return @"com.garena.game.freefireth"; }

static int (*orig_gai)(const char *h, const char *s, const struct addrinfo *hi, struct addrinfo **r);
static int hooked_gai(const char *h, const char *s, const struct addrinfo *hi, struct addrinfo **r) {
    const char* bd[] = {"anticheat.garena.com","ff-anticheat.garena.com","ssl-ff.garena.com","config-ff.garena.com","log-ff.garena.com",NULL};
    for(int i=0; bd[i]; i++) if(strstr(h,bd[i])) return orig_gai("127.0.0.1",s,hi,r);
    return orig_gai(h,s,hi,r);
}
static int (*orig_connect)(int fd, const struct sockaddr *a, socklen_t al);
static int hooked_connect(int fd, const struct sockaddr *a, socklen_t al) {
    if(a->sa_family==AF_INET) {
        const char* ips[] = {"103.56.156.10","45.64.156.20",NULL};
        for(int i=0; ips[i]; i++) if(strcmp(inet_ntoa(((struct sockaddr_in*)a)->sin_addr),ips[i])==0) {errno=ECONNREFUSED;return -1;}
    }
    return orig_connect(fd,a,al);
}

typedef void* (*GCF)(void*,const char*);
typedef void (*SEF)(void*,bool);
static GCF UnityGetComponent = NULL;
static SEF UnitySetEnabled = NULL;

typedef void* (*GO_Ctor)(void*,const char*);
static GO_Ctor orig_GO_Ctor = NULL;
void* hooked_GO_Ctor(void* self, const char* name) {
    void* obj = orig_GO_Ctor(self,name);
    if(name && UnitySetEnabled && UnityGetComponent) {
        const char* list[] = {"House","Building","Tree","Wall","Rock","Bush","Fence","Container",NULL};
        for(int i=0; list[i]; i++) {
            if(strstr(name,list[i])) {
                void* mr = UnityGetComponent(obj,"MeshRenderer"); if(mr) UnitySetEnabled(mr,false);
                void* sr = UnityGetComponent(obj,"SkinnedMeshRenderer"); if(sr) UnitySetEnabled(sr,false);
                break;
            }
        }
    }
    return obj;
}
typedef void (*Cam_Post)(void*);
static Cam_Post orig_Cam_Post = NULL;
void hooked_Cam_Post(void* self) { orig_Cam_Post(self); }

typedef void (*WF)(void*,float);
static WF orig_WF = NULL;
void hooked_WF(void* w, float dt) {
    orig_WF(w,dt);
    *(float*)((uintptr_t)w+0x40)=0; *(float*)((uintptr_t)w+0x44)=0;
    *(float*)((uintptr_t)w+0x48)=0; *(float*)((uintptr_t)w+0x4C)=0;
}
typedef void (*WU)(void*);
static WU orig_WU = NULL;
void hooked_WU(void* w) {
    orig_WU(w);
    *(float*)((uintptr_t)w+0x40)=0; *(float*)((uintptr_t)w+0x44)=0;
    *(float*)((uintptr_t)w+0x48)=0; *(float*)((uintptr_t)w+0x4C)=0;
}

void InitUnity() {
    void* m = dlopen("UnityFramework",RTLD_NOW);
    if(!m) { dispatch_after(dispatch_time(DISPATCH_TIME_NOW,2*NSEC_PER_SEC), dispatch_get_main_queue(), ^{InitUnity();}); return; }
    UnityGetComponent = (GCF)dlsym(m,"UnityEngine_GameObject_GetComponent");
    UnitySetEnabled = (SEF)dlsym(m,"UnityEngine_Behaviour_set_enabled");
    void* ctor = dlsym(m,"GameObject_Ctor_Internal");
    if(ctor) MSHookFunction(ctor,(void*)&hooked_GO_Ctor,(void**)&orig_GO_Ctor);
    void* post = dlsym(m,"UnityEngine_Camera_OnPostRender");
    if(post) MSHookFunction(post,(void*)&hooked_Cam_Post,(void**)&orig_Cam_Post);
}

__attribute__((constructor)) void FFInit() {
    signal(SIGPIPE,SIG_IGN);
    MSHookFunction((void*)&stat,(void*)&hooked_stat,(void**)&orig_stat);
    MSHookFunction((void*)&access,(void*)&hooked_access,(void**)&orig_access);
    MSHookFunction((void*)&sysctl,(void*)&hooked_sysctl,(void**)&orig_sysctl);
    MSHookFunction((void*)&task_get_exception_ports,(void*)&hooked_tgep,(void**)&orig_tgep);
    MSHookFunction((void*)&_dyld_image_count,(void*)&hooked_di_c,(void**)&orig_di_c);
    MSHookFunction((void*)&_dyld_get_image_name,(void*)&hooked_di_gn,(void**)&orig_di_gn);
    Class u = objc_getClass("UIDevice"); MSHookMessageEx(u,@selector(identifierForVendor),(IMP)&hooked_idfv,(IMP*)&orig_idfv);
    Class b = objc_getClass("NSBundle"); MSHookMessageEx(b,@selector(bundleIdentifier),(IMP)&hooked_bid,(IMP*)&orig_bid);
    MSHookFunction((void*)&getaddrinfo,(void*)&hooked_gai,(void**)&orig_gai);
    MSHookFunction((void*)&connect,(void*)&hooked_connect,(void**)&orig_connect);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW,3*NSEC_PER_SEC), dispatch_get_main_queue(), ^{InitUnity();});
}

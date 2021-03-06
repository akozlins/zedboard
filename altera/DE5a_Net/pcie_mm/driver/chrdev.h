
#include <linux/uaccess.h>

struct chrdev_t {
    dev_t dev;
    int major;
    struct class* class;
};
static struct chrdev_t chrdev;

static
int chrdev_open(struct inode* inode, struct file* file) {
    pr_info("[%s] chrdev_open(iminor = %d)\n", pci_name(a10_pcie.pci_dev), iminor(inode));

    file->private_data = &a10_pcie.bars[iminor(inode)];

    return 0;
}

static
ssize_t chrdev_read(struct file* file, char __user* user_buffer, size_t size, loff_t* offset) {
    ssize_t n = 0;
    struct bar_t* bar = file->private_data;

    pr_info("[%s] chrdev_read(size = %ld, offset = %lld)\n", pci_name(a10_pcie.pci_dev), size, *offset);

    while(n < size && *offset < bar->len) {
        u32 buffer = ioread32(bar->ptr + *offset);
        if(copy_to_user(user_buffer + n, (void*)&buffer, 4)) {
            return -EFAULT;
        }
        *offset += 4;
        n += 4;
    }

    return n;
}

static
long ioctl(struct file* file, unsigned int cmd, unsigned long arg) {
    return -EINVAL;
}

static
struct file_operations fops = {
    .owner = THIS_MODULE,
    .open = chrdev_open,
    .read = chrdev_read,
    .unlocked_ioctl = ioctl,
};

static
void chrdev_fini(void) {
    class_destroy(chrdev.class);
    if(chrdev.major) unregister_chrdev_region(MKDEV(chrdev.major, 0), 6);
}

static
int chrdev_init(void) {
    int err;

    // allocate char device (get major number and reserve range of minor numbers)
    err = alloc_chrdev_region(&chrdev.dev, 0, 6, DEVICE_NAME);
    if(err) {
        pr_warn("[%s] alloc_chrdev_region() failed\n", DEVICE_NAME);
        goto fail;
    }
    chrdev.major = MAJOR(chrdev.dev);

    // create struct class pointer that is used by device_create()
    chrdev.class = class_create(THIS_MODULE, DEVICE_NAME);
    if(IS_ERR(chrdev.class)) {
        pr_warn("[%s] class_create() failed\n", DEVICE_NAME);
        err = PTR_ERR(chrdev.class);
        goto fail;
    }

    return 0;

fail:
    chrdev_fini();
    return err;
}

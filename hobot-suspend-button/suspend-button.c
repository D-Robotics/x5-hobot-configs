// Copyright (c) 2024, D-Robotics.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <unistd.h>
#include <linux/input.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <errno.h>

int main() {
    int fd;
    int count = 0;
    struct input_event ie;

    fd = open("/dev/input/event0", O_RDONLY);
    if (fd == -1) {
        perror("Failed to open device");
        return EXIT_FAILURE;
    }

    while (1) {
        ssize_t bytes = read(fd, &ie, sizeof(struct input_event));
        if (bytes == (ssize_t) sizeof(struct input_event)) {
            if (ie.type == EV_KEY && ie.code == 143) {
                if (ie.value == 2) {
                    count = 1;
                }
                if (count == 1 && ie.value == 0) {
                    count = 0;

                    pid_t pid = fork();
                    if (pid == 0) {
                        execl("/usr/bin/hobot-suspend", "hobot-suspend", NULL);
                        perror("execl failed");
                        _exit(EXIT_FAILURE);
                    } else if (pid < 0) {
                        perror("fork failed");
                    }
                }
            }
        } else {
            perror("Failed to read event");
            close(fd);
            return EXIT_FAILURE;
        }
        while (waitpid(-1, NULL, WNOHANG) > 0) {}
    }

    close(fd);
    return EXIT_SUCCESS;
}
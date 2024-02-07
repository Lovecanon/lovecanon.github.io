package main

import (
	"bytes"
	"fmt"
	"log"
	"os"
	"os/exec"
	"strings"
	"time"
)

func main() {
	content, err := os.ReadFile("tv/tv.m3u")
	if err != nil {
		log.Fatal(err)
	}

	lines := strings.Split(string(content), "\n")

	urls := []string{}
	for _, line := range lines {
		if strings.HasPrefix(line, "http") && strings.HasSuffix(line, "m3u8") {
			urls = append(urls, strings.TrimSpace(line))
		}
	}

	for i, u := range urls {
		now := time.Now()
		err = check(u)
		if err != nil {
			log.Printf("[%d][FAIL]%s, err: %v", i, u, err)
		} else {
			log.Printf("[%d][SUCCESS %.3f]%s", i, time.Since(now).Seconds(), u)
		}
	}
}

func check(link string) error {
	cmd := exec.Command("ffprobe", "-v", "quiet", "-show_streams", link)

	stdio := new(bytes.Buffer)
	cmd.Stdout = stdio
	cmd.Stderr = stdio

	errch := make(chan error)
	go func() {
		err := cmd.Run()
		errch <- err
	}()

	select {
	case <-time.After(time.Second * 5):
		return fmt.Errorf("timout")
	case e := <-errch:
		if e != nil {
			return fmt.Errorf("%s, std: %s", e.Error(), stdio.String())
		}
		if !strings.Contains(stdio.String(), "[/STREAM]") {
			return fmt.Errorf("响应值错误, %s", stdio.String())
		}
	}
	return nil
}

type StreamInfo struct {
	CodecName string
	Width     int
	Height    int
	FrameRate int // avg_frame_rate
}

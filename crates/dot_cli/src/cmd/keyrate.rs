//! `dot keyrate`: key repeat delay/rate beyond the Windows settings UI limits,
//! via the FilterKeys accessibility feature (SystemParametersInfo SPI_SETFILTERKEYS).
//!
//! Based on https://gist.github.com/t-mat/8771347 (formerly keyrate.ps1).

use anyhow::Result;

/// What to do.
#[cfg_attr(not(windows), allow(dead_code))]
pub enum Request {
    Set {
        delay_ms: u32,
        repeat_ms: u32,
        persist: bool,
    },
    Off {
        persist: bool,
    },
    Show,
}

#[cfg(windows)]
mod sys {
    use std::ffi::c_void;

    pub const SPI_GETFILTERKEYS: u32 = 0x0032;
    pub const SPI_SETFILTERKEYS: u32 = 0x0033;
    pub const FKF_FILTERKEYSON: u32 = 0x0001;
    pub const FKF_AVAILABLE: u32 = 0x0002;
    /// Write to the user profile (survives reboot) and broadcast WM_SETTINGCHANGE.
    pub const SPIF_UPDATEINIFILE_SENDCHANGE: u32 = 0x0001 | 0x0002;

    #[repr(C)]
    #[derive(Default, Debug)]
    pub struct FilterKeys {
        pub cb_size: u32,
        pub dw_flags: u32,
        pub i_wait_msec: u32,
        pub i_delay_msec: u32,
        pub i_repeat_msec: u32,
        pub i_bounce_msec: u32,
    }

    #[link(name = "user32")]
    unsafe extern "system" {
        pub fn SystemParametersInfoW(action: u32, param: u32, pv: *mut c_void, win_ini: u32)
        -> i32;
    }

    pub fn call(action: u32, fk: &mut FilterKeys, win_ini: u32) -> std::io::Result<()> {
        fk.cb_size = size_of::<FilterKeys>() as u32;
        // SAFETY: `fk` is a valid, properly sized FILTERKEYS for the duration of the call.
        let ok = unsafe {
            SystemParametersInfoW(action, fk.cb_size, std::ptr::from_mut(fk).cast(), win_ini)
        };
        if ok == 0 {
            Err(std::io::Error::last_os_error())
        } else {
            Ok(())
        }
    }
}

#[cfg(windows)]
pub fn run(req: Request) -> Result<()> {
    use sys::*;
    let flags = |persist: bool| {
        if persist {
            SPIF_UPDATEINIFILE_SENDCHANGE
        } else {
            0
        }
    };
    match req {
        Request::Show => {
            let mut fk = FilterKeys::default();
            call(SPI_GETFILTERKEYS, &mut fk, 0)?;
            if fk.dw_flags & FKF_FILTERKEYSON == 0 {
                println!("keyrate: off (Windows keyboard settings apply)");
            } else {
                println!(
                    "keyrate: delay={}ms repeat={}ms",
                    fk.i_delay_msec, fk.i_repeat_msec
                );
            }
        }
        Request::Set {
            delay_ms,
            repeat_ms,
            persist,
        } => {
            let mut fk = FilterKeys {
                dw_flags: FKF_FILTERKEYSON | FKF_AVAILABLE,
                i_delay_msec: delay_ms,
                i_repeat_msec: repeat_ms,
                ..Default::default()
            };
            call(SPI_SETFILTERKEYS, &mut fk, flags(persist))?;
            println!(
                "keyrate: delay={delay_ms}ms repeat={repeat_ms}ms{}",
                if persist { " (persistent)" } else { "" }
            );
        }
        Request::Off { persist } => {
            let mut fk = FilterKeys::default();
            call(SPI_SETFILTERKEYS, &mut fk, flags(persist))?;
            println!("keyrate: off");
        }
    }
    Ok(())
}

#[cfg(not(windows))]
pub fn run(_req: Request) -> Result<()> {
    anyhow::bail!("`dot keyrate` is Windows-only (on X11 use `xset r rate <delay> <hz>`)")
}
